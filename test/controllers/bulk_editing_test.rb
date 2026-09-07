require "test_helper"

class BulkEditingTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email: "bulk-admin@example.com", name: "一括管理者", role: :admin, password: "password123")
    @staff = User.create!(email: "bulk-staff@example.com", name: "一般担当者", role: :staff, password: "password123")
    @course1 = Course.create!(code: "B-C01", name: "更新前コース1", active: true, sort_order: 1)
    @course2 = Course.create!(code: "B-C02", name: "更新前コース2", active: true, sort_order: 2)
  end

  test "管理者は表から複数更新と新規登録を一括保存できる" do
    sign_in @admin

    assert_difference("Course.count", 1) do
      patch bulk_update_courses_path, params: {
        records: {
          @course1.id.to_s => { code: "B-C01", name: "更新後コース1", active: "1", sort_order: "10" },
          @course2.id.to_s => { code: "B-C02", name: "更新後コース2", active: "0", sort_order: "20" },
          "new_1" => { code: "B-C03", name: "新規コース", active: "1", sort_order: "30" }
        }
      }
    end

    assert_redirected_to courses_path
    assert_equal [ "更新後コース1", 10 ], [ @course1.reload.name, @course1.sort_order ]
    assert_not @course2.reload.active?
    assert Course.exists?(code: "B-C03", name: "新規コース")
  end

  test "一行でも不正なら全行をロールバックして行エラーを表示する" do
    sign_in @admin

    assert_no_changes -> { @course1.reload.name } do
      patch bulk_update_courses_path, params: {
        records: {
          @course1.id.to_s => { code: "B-C01", name: "保存されない名称", active: "1", sort_order: "1" },
          @course2.id.to_s => { code: "B-C02", name: "", active: "1", sort_order: "2" }
        }
      }
    end

    assert_response :unprocessable_content
    assert_select "[role='alert']", /保存できません/
    assert_select "[aria-invalid='true']"
  end

  test "一般担当者は取引先を表で閲覧できるが一括更新できない" do
    client = Client.create!(code: "B-CL01", name: "閲覧用取引先")
    sign_in @staff

    get clients_path
    assert_response :success
    assert_select "table"
    assert_select "input[name^='records']", count: 0

    patch bulk_update_clients_path, params: {
      records: { client.id.to_s => { code: "B-CL01", name: "不正更新", active: "1" } }
    }
    assert_redirected_to clients_path
    assert_equal "閲覧用取引先", client.reload.name
  end

  test "店舗の新規行は取引先を名称選択して登録できる" do
    client = Client.create!(code: "B-CL02", name: "選択先取引先")
    sign_in @admin

    get stores_path
    assert_response :success
    assert_select "select[name*='client_id'] option", text: "選択先取引先"

    assert_difference("Store.count", 1) do
      patch bulk_update_stores_path, params: {
        records: {
          "new_1" => {
            client_id: client.id,
            code: "B-ST01",
            name: "一括登録店舗",
            active: "1",
            pending_review: "1"
          }
        }
      }
    end
    store = Store.find_by!(code: "B-ST01")
    assert_equal client, store.client
    assert_equal @admin, store.created_by
    assert_not store.pending_review?
  end

  test "按分比率の期間重複時は新規行を全てロールバックする" do
    group = CargoCategoryGroup.create!(name: "一括按分グループ")
    sign_in @admin

    assert_no_difference("AllocationRatio.count") do
      patch bulk_update_allocation_ratios_path, params: {
        records: {
          "new_1" => {
            cargo_category_group_id: group.id,
            ratio: "0.5000",
            effective_from: "2026-01-01",
            effective_to: "2026-12-31"
          },
          "new_2" => {
            cargo_category_group_id: group.id,
            ratio: "0.6000",
            effective_from: "2026-06-01",
            effective_to: ""
          }
        }
      }
    end

    assert_response :unprocessable_content
    assert_select "[role='alert']", /重複/
  end

  test "空の新規行は登録対象にしない" do
    sign_in @admin

    assert_no_difference("Course.count") do
      patch bulk_update_courses_path, params: {
        records: { "new_1" => { code: "", name: "", active: "1", sort_order: "0" } }
      }
    end
    assert_redirected_to courses_path
  end

  test "全管理マスタを表形式で表示できる" do
    company = DeliveryCompany.create!(code: "B-DC01", name: "一括運送")
    Vehicle.create!(code: "B-V01", delivery_company: company)
    Driver.create!(code: "B-D01", name: "一括 太郎", delivery_company: company)
    group = CargoCategoryGroup.create!(name: "一括カテゴリ")
    CargoCategory.create!(code: "B-CG01", name: "一括荷物", cargo_category_group: group)
    Unit.create!(code: "B-U01", name: "箱")
    AllocationRatio.create!(cargo_category_group: group, ratio: 0.5, effective_from: Date.new(2026, 1, 1))
    sign_in @admin

    [
      courses_path,
      delivery_companies_path,
      vehicles_path,
      drivers_path,
      cargo_category_groups_path,
      cargo_categories_path,
      units_path,
      allocation_ratios_path
    ].each do |path|
      get path
      assert_response :success, "#{path}を表示できること"
      assert_select "table"
      assert_select "[data-controller='bulk-editor']"
    end
  end
end
