require "test_helper"

class DeliveryManagementTest < ActiveSupport::TestCase
  setup do
    @company = DeliveryCompany.create!(code: "DC-T", name: "試験運送")
    @course = Course.create!(code: "C-T", name: "試験コース")
    @vehicle = Vehicle.create!(code: "V-T", delivery_company: @company)
    @driver = Driver.create!(code: "D-T", name: "試験 太郎", delivery_company: @company)
    @group = CargoCategoryGroup.create!(name: "試験グループ")
    @category = CargoCategory.create!(code: "CG-T", name: "試験荷物", cargo_category_group: @group)
    @unit = Unit.create!(code: "U-T", name: "個")
    @client = Client.create!(code: "CL-T", name: "青空商事")
    @store = Store.create!(code: "ST-T", name: "本店", client: @client)
  end

  test "取引先名をtrigramであいまい検索できる" do
    assert_includes Client.search_by_name("青空"), @client
  end

  test "仮登録はコードなしで保存できる" do
    assert Client.create(name: "仮取引先", pending_review: true).persisted?
  end

  test "配送会社と車両の不一致を拒否する" do
    another_company = DeliveryCompany.create!(code: "DC-X", name: "別会社")
    record = build_record(delivery_company: another_company)

    assert_not record.valid?
    assert record.errors[:vehicle].any?
  end

  test "日跨ぎ運行を判定できる" do
    departure = Time.zone.parse("2026-09-01 23:00")
    assert build_record(departure_at: departure, arrival_at: departure + 2.hours).overnight?
  end

  test "按分比率の期間重複を拒否する" do
    AllocationRatio.create!(cargo_category_group: @group, ratio: 0.5, effective_from: Date.new(2026, 1, 1))
    duplicate = AllocationRatio.new(cargo_category_group: @group, ratio: 0.6, effective_from: Date.new(2026, 2, 1))

    assert_not duplicate.valid?
  end

  private

  def build_record(attributes = {})
    defaults = {
      service_date: Date.current,
      course: @course,
      delivery_company: @company,
      vehicle: @vehicle,
      driver: @driver,
      cargo_category: @category,
      client: @client,
      store: @store,
      volume: 12,
      unit: @unit,
      departure_at: Time.current,
      arrival_at: 2.hours.from_now
    }
    DeliveryRecord.new(defaults.merge(attributes))
  end
end
