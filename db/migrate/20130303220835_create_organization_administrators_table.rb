class CreateOrganizationAdministratorsTable < ActiveRecord::Migration
  def up
    create_table :organization_administrators, :id => false do |t|
        t.references :organization
        t.references :user
    end
    add_index :organization_administrators, [:organization_id, :user_id]
  end

  def down
    drop_table :organization_administrators
  end
end
