require "test_helper"

class WorkflowsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email: "admin-test@example.com", name: "管理者", role: :admin, password: "password123")
    @staff = User.create!(email: "staff-test@example.com", name: "担当者", role: :staff, password: "password123")
    @company = DeliveryCompany.create!(code: "DC-W", name: "試験運送")
    @course = Course.create!(code: "C-W", name: "試験便")
    @vehicle = Vehicle.create!(code: "V-W", delivery_company: @company)
    @driver = Driver.create!(code: "D-W", name: "試験担当", delivery_company: @company)
    group = CargoCategoryGroup.create!(name: "試験分類")
    @category = CargoCategory.create!(code: "CG-W", name: "試験荷物", cargo_category_group: group)
    @unit = Unit.create!(code: "U-W", name: "個")
    @client = Client.create!(code: "CL-W", name: "正式取引先")
  end

  test "未ログインならログイン画面へ遷移する" do
    get delivery_records_path
    assert_redirected_to new_user_session_path
  end

  test "staffは管理マスタへアクセスできない" do
    sign_in @staff
    get courses_path
    assert_redirected_to root_path
  end

  test "配送実績の監査ユーザーをサーバー側で設定する" do
    sign_in @staff
    assert_difference("DeliveryRecord.count") do
      post delivery_records_path, params: { delivery_record: valid_record_params }
    end
    assert_equal @staff, DeliveryRecord.last.created_by
    assert_equal @staff, DeliveryRecord.last.updated_by
  end

  test "配送実績登録画面を表示できる" do
    sign_in @staff
    get new_delivery_record_path
    assert_response :success
    assert_select "form"
    assert_select "[data-controller='delivery-form']"
  end

  test "staffが取引先を仮登録できる" do
    sign_in @staff
    post quick_create_clients_path, params: { name: "仮登録商店" }, as: :json
    assert_response :created
    assert Client.last.pending_review?
    assert_equal @staff, Client.last.created_by
  end

  test "adminが仮登録を正式化できる" do
    pending = Client.create!(name: "審査待ち", pending_review: true, created_by: @staff)
    sign_in @admin
    patch approve_admin_review_path(pending, type: "client"), params: { code: "CL-NEW" }
    assert_redirected_to admin_reviews_path
    assert_equal "CL-NEW", pending.reload.code
    assert_not pending.pending_review?
  end

  test "adminが仮登録審査画面を表示できる" do
    Client.create!(name: "画面確認待ち", pending_review: true, created_by: @staff)
    sign_in @admin
    get admin_reviews_path
    assert_response :success
    assert_select "h1", "仮登録審査"
  end

  test "adminが仮取引先を既存取引先へ統合できる" do
    pending = Client.create!(name: "重複取引先", pending_review: true, created_by: @staff)
    record = DeliveryRecord.create!(valid_record_params.merge(client_id: pending.id, created_by: @staff))
    sign_in @admin

    post merge_admin_review_path(pending, type: "client"), params: { target_id: @client.id }

    assert_redirected_to admin_reviews_path
    assert_equal @client, record.reload.client
    assert_not pending.reload.active?
  end

  private

  def valid_record_params
    {
      service_date: Date.current,
      course_id: @course.id,
      delivery_company_id: @company.id,
      vehicle_id: @vehicle.id,
      driver_id: @driver.id,
      cargo_category_id: @category.id,
      client_id: @client.id,
      volume: 10,
      unit_id: @unit.id,
      departure_at: Time.current
    }
  end
end
