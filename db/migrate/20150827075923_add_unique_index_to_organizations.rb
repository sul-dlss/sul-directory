class AddUniqueIndexToOrganizations < ActiveRecord::Migration
  def change
    add_index :organizations, :admin_id, unique: true
  end
end
