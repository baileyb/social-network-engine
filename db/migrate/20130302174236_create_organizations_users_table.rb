class CreateOrganizationsUsersTable < ActiveRecord::Migration
  def up
    create_table :organizations_users, :id => false do |t|
        t.references :organization
        t.references :user
    end
    add_index :organizations_users, [:organization_id, :user_id]
  end

  def down
    drop_table :organizations_users
  end
end
