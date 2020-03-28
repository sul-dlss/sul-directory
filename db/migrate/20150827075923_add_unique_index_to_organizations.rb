class AddUniqueIndexToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_index :organizations, :admin_id, unique: true
  end
end
