json.extract! delivery_record, :id, :service_date, :course_id, :delivery_company_id, :vehicle_id, :driver_id, :cargo_category_id, :client_id, :store_id, :volume, :unit_id, :departure_at, :arrival_at, :created_by_id, :updated_by_id, :created_at, :updated_at
json.url delivery_record_url(delivery_record, format: :json)
