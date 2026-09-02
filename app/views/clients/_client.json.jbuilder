json.extract! client, :id, :code, :name, :active, :pending_review, :created_by_id, :created_at, :updated_at
json.url client_url(client, format: :json)
