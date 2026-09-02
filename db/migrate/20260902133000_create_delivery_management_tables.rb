class CreateDeliveryManagementTables < ActiveRecord::Migration[7.2]
  def change
    enable_extension "pg_trgm"

    create_table :courses do |t|
      t.string :code
      t.string :name, null: false
      t.boolean :active, default: true, null: false
      t.integer :sort_order, default: 0, null: false
      t.timestamps
    end
    add_index :courses, :code, unique: true

    create_table :delivery_companies do |t|
      t.string :code
      t.string :name, null: false
      t.boolean :active, default: true, null: false
      t.integer :sort_order, default: 0, null: false
      t.timestamps
    end
    add_index :delivery_companies, :code, unique: true

    create_table :vehicles do |t|
      t.string :code
      t.references :delivery_company, foreign_key: true
      t.boolean :active, default: true, null: false
      t.integer :sort_order, default: 0, null: false
      t.timestamps
    end
    add_index :vehicles, :code, unique: true

    create_table :drivers do |t|
      t.string :code
      t.string :name, null: false
      t.references :delivery_company, foreign_key: true
      t.boolean :active, default: true, null: false
      t.integer :sort_order, default: 0, null: false
      t.timestamps
    end

    create_table :cargo_category_groups do |t|
      t.string :name, null: false
      t.integer :sort_order, default: 0, null: false
      t.timestamps
    end

    create_table :cargo_categories do |t|
      t.string :code
      t.string :name, null: false
      t.references :cargo_category_group, null: false, foreign_key: true
      t.boolean :active, default: true, null: false
      t.integer :sort_order, default: 0, null: false
      t.timestamps
    end

    create_table :units do |t|
      t.string :code
      t.string :name, null: false
      t.boolean :active, default: true, null: false
      t.integer :sort_order, default: 0, null: false
      t.timestamps
    end

    create_table :clients do |t|
      t.string :code
      t.string :name, null: false
      t.boolean :active, default: true, null: false
      t.boolean :pending_review, default: false, null: false
      t.references :created_by, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :clients, :code, unique: true
    add_index :clients, :name
    add_index :clients, :name, using: :gin, opclass: :gin_trgm_ops, name: "index_clients_on_name_trigram"

    create_table :stores do |t|
      t.references :client, foreign_key: true
      t.string :code
      t.string :name, null: false
      t.boolean :active, default: true, null: false
      t.boolean :pending_review, default: false, null: false
      t.references :created_by, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :stores, :code, unique: true
    add_index :stores, :name
    add_index :stores, :name, using: :gin, opclass: :gin_trgm_ops, name: "index_stores_on_name_trigram"

    create_table :delivery_records do |t|
      t.date :service_date, null: false
      t.references :course, null: false, foreign_key: true
      t.references :delivery_company, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.references :driver, null: false, foreign_key: true
      t.references :cargo_category, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.references :store, foreign_key: true
      t.decimal :volume, precision: 10, scale: 2, null: false
      t.references :unit, null: false, foreign_key: true
      t.datetime :departure_at, null: false
      t.datetime :arrival_at
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :delivery_records, %i[service_date course_id]

    create_table :allocation_ratios do |t|
      t.references :cargo_category_group, null: false, foreign_key: true
      t.decimal :ratio, precision: 5, scale: 4, null: false
      t.date :effective_from, null: false
      t.date :effective_to
      t.timestamps
    end

    add_check_constraint :allocation_ratios, "ratio >= 0 AND ratio <= 1", name: "allocation_ratio_range"
    add_check_constraint :allocation_ratios,
      "effective_to IS NULL OR effective_to >= effective_from",
      name: "allocation_ratio_valid_period"
  end
end
