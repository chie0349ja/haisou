admin = User.find_or_initialize_by(email: "admin@example.com")
admin.update!(name: "配送管理者", role: :admin, password: "password123", password_confirmation: "password123")
staff = User.find_or_initialize_by(email: "staff@example.com")
staff.update!(name: "配送担当者", role: :staff, password: "password123", password_confirmation: "password123")

def seed_master(model, rows)
  rows.each_with_index do |(code, name), index|
    record = model.find_or_initialize_by(code: code)
    record.assign_attributes(name: name, active: true, sort_order: index + 1)
    record.save!
  end
end

seed_master(Course, [ [ "C01", "都内午前便" ], [ "C02", "都内午後便" ], [ "C03", "神奈川便" ], [ "C04", "千葉便" ], [ "C05", "埼玉便" ] ])
seed_master(DeliveryCompany, [ [ "DC01", "東都運輸" ], [ "DC02", "中央物流" ], [ "DC03", "北関東便" ], [ "DC04", "湾岸配送" ], [ "DC05", "みらい運送" ] ])
seed_master(Unit, [ [ "U01", "個" ], [ "U02", "kg" ], [ "U03", "ケース" ], [ "U04", "パレット" ], [ "U05", "台" ] ])

companies = DeliveryCompany.ordered.to_a
5.times do |index|
  vehicle = Vehicle.find_or_initialize_by(code: "V#{format('%02d', index + 1)}")
  vehicle.update!(delivery_company: companies[index], active: true, sort_order: index + 1)
  driver = Driver.find_or_initialize_by(code: "D#{format('%02d', index + 1)}")
  driver.update!(name: [ "山田 太郎", "佐藤 花子", "鈴木 一郎", "高橋 美咲", "田中 健" ][index], delivery_company: companies[index], active: true, sort_order: index + 1)
end

groups = [ "常温品", "冷蔵品", "冷凍品", "精密機器", "その他" ].each_with_index.map do |name, index|
  CargoCategoryGroup.find_or_create_by!(name: name) { |group| group.sort_order = index + 1 }
end
5.times do |index|
  category = CargoCategory.find_or_initialize_by(code: "CG#{format('%02d', index + 1)}")
  category.update!(name: [ "一般食品", "乳製品", "冷凍食品", "電子部品", "資材" ][index], cargo_category_group: groups[index], active: true, sort_order: index + 1)
  AllocationRatio.find_or_create_by!(cargo_category_group: groups[index], effective_from: Date.new(2026, 1, 1)) do |ratio|
    ratio.ratio = [ 0.35, 0.25, 0.2, 0.15, 0.05 ][index]
  end
end

clients = 5.times.map do |index|
  client = Client.find_or_initialize_by(code: "CL#{format('%03d', index + 1)}")
  client.update!(name: [ "青空商事", "さくら食品", "東京販売", "港湾ストア", "北斗産業" ][index], active: true, pending_review: false, created_by: admin)
  client
end
stores = clients.each_with_index.map do |client, index|
  store = Store.find_or_initialize_by(code: "ST#{format('%03d', index + 1)}")
  store.update!(name: "#{client.name} #{[ '本店', '新宿店', '品川店', '横浜店', '大宮店' ][index]}", client: client, active: true, pending_review: false, created_by: admin)
  store
end

10.times do |index|
  company = companies[index % companies.length]
  record = DeliveryRecord.find_or_initialize_by(service_date: Date.current - index.days, course: Course.ordered[index % 5])
  departure = (Date.current - index.days).in_time_zone.change(hour: 8 + (index % 3))
  record.update!(
    delivery_company: company,
    vehicle: company.vehicles.first,
    driver: company.drivers.first,
    cargo_category: CargoCategory.ordered[index % 5],
    client: clients[index % 5],
    store: stores[index % 5],
    volume: 10 + index * 2.5,
    unit: Unit.ordered[index % 5],
    departure_at: departure,
    arrival_at: departure + (index == 9 ? 18.hours : 4.hours),
    created_by: staff,
    updated_by: staff
  )
end
