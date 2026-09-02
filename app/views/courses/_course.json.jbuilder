json.extract! course, :id, :code, :name, :active, :sort_order, :created_at, :updated_at
json.url course_url(course, format: :json)
