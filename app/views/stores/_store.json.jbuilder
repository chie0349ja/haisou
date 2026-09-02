json.extract! store, :id, :client_id, :code, :name, :active, :pending_review, :created_by_id, :created_at, :updated_at
json.url store_url(store, format: :json)
