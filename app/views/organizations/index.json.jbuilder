json.array!(@organizations) do |organization|
  json.extract! organization, :id, :code, :level, :name, :parent_id
  json.url organization_url(organization, format: :json)
end
