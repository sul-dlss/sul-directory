json.array!(@organizations) do |organization|
  json.extract! organization, :id, :admin_id, :name, :parent_id
  json.url organization_url(organization, format: :json)
end
