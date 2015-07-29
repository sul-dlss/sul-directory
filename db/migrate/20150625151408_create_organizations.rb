class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :admin_id
      t.string :name
      t.integer :parent_id

      t.timestamps null: false
    end
  end
end
