# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_09_02_133000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "allocation_ratios", force: :cascade do |t|
    t.bigint "cargo_category_group_id", null: false
    t.decimal "ratio", precision: 5, scale: 4, null: false
    t.date "effective_from", null: false
    t.date "effective_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cargo_category_group_id"], name: "index_allocation_ratios_on_cargo_category_group_id"
    t.check_constraint "effective_to IS NULL OR effective_to >= effective_from", name: "allocation_ratio_valid_period"
    t.check_constraint "ratio >= 0::numeric AND ratio <= 1::numeric", name: "allocation_ratio_range"
  end

  create_table "cargo_categories", force: :cascade do |t|
    t.string "code"
    t.string "name", null: false
    t.bigint "cargo_category_group_id", null: false
    t.boolean "active", default: true, null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cargo_category_group_id"], name: "index_cargo_categories_on_cargo_category_group_id"
  end

  create_table "cargo_category_groups", force: :cascade do |t|
    t.string "name", null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", force: :cascade do |t|
    t.string "code"
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.boolean "pending_review", default: false, null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_clients_on_code", unique: true
    t.index ["created_by_id"], name: "index_clients_on_created_by_id"
    t.index ["name"], name: "index_clients_on_name"
    t.index ["name"], name: "index_clients_on_name_trigram", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "courses", force: :cascade do |t|
    t.string "code"
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_courses_on_code", unique: true
  end

  create_table "delivery_companies", force: :cascade do |t|
    t.string "code"
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_delivery_companies_on_code", unique: true
  end

  create_table "delivery_records", force: :cascade do |t|
    t.date "service_date", null: false
    t.bigint "course_id", null: false
    t.bigint "delivery_company_id", null: false
    t.bigint "vehicle_id", null: false
    t.bigint "driver_id", null: false
    t.bigint "cargo_category_id", null: false
    t.bigint "client_id", null: false
    t.bigint "store_id"
    t.decimal "volume", precision: 10, scale: 2, null: false
    t.bigint "unit_id", null: false
    t.datetime "departure_at", null: false
    t.datetime "arrival_at"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cargo_category_id"], name: "index_delivery_records_on_cargo_category_id"
    t.index ["client_id"], name: "index_delivery_records_on_client_id"
    t.index ["course_id"], name: "index_delivery_records_on_course_id"
    t.index ["created_by_id"], name: "index_delivery_records_on_created_by_id"
    t.index ["delivery_company_id"], name: "index_delivery_records_on_delivery_company_id"
    t.index ["driver_id"], name: "index_delivery_records_on_driver_id"
    t.index ["service_date", "course_id"], name: "index_delivery_records_on_service_date_and_course_id"
    t.index ["store_id"], name: "index_delivery_records_on_store_id"
    t.index ["unit_id"], name: "index_delivery_records_on_unit_id"
    t.index ["updated_by_id"], name: "index_delivery_records_on_updated_by_id"
    t.index ["vehicle_id"], name: "index_delivery_records_on_vehicle_id"
  end

  create_table "drivers", force: :cascade do |t|
    t.string "code"
    t.string "name", null: false
    t.bigint "delivery_company_id"
    t.boolean "active", default: true, null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_company_id"], name: "index_drivers_on_delivery_company_id"
  end

  create_table "stores", force: :cascade do |t|
    t.bigint "client_id"
    t.string "code"
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.boolean "pending_review", default: false, null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_stores_on_client_id"
    t.index ["code"], name: "index_stores_on_code", unique: true
    t.index ["created_by_id"], name: "index_stores_on_created_by_id"
    t.index ["name"], name: "index_stores_on_name"
    t.index ["name"], name: "index_stores_on_name_trigram", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "units", force: :cascade do |t|
    t.string "code"
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.string "role", default: "staff", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "code"
    t.bigint "delivery_company_id"
    t.boolean "active", default: true, null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_vehicles_on_code", unique: true
    t.index ["delivery_company_id"], name: "index_vehicles_on_delivery_company_id"
  end

  add_foreign_key "allocation_ratios", "cargo_category_groups"
  add_foreign_key "cargo_categories", "cargo_category_groups"
  add_foreign_key "clients", "users", column: "created_by_id"
  add_foreign_key "delivery_records", "cargo_categories"
  add_foreign_key "delivery_records", "clients"
  add_foreign_key "delivery_records", "courses"
  add_foreign_key "delivery_records", "delivery_companies"
  add_foreign_key "delivery_records", "drivers"
  add_foreign_key "delivery_records", "stores"
  add_foreign_key "delivery_records", "units"
  add_foreign_key "delivery_records", "users", column: "created_by_id"
  add_foreign_key "delivery_records", "users", column: "updated_by_id"
  add_foreign_key "delivery_records", "vehicles"
  add_foreign_key "drivers", "delivery_companies"
  add_foreign_key "stores", "clients"
  add_foreign_key "stores", "users", column: "created_by_id"
  add_foreign_key "vehicles", "delivery_companies"
end
