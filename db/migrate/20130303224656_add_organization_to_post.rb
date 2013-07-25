class AddOrganizationToPost < ActiveRecord::Migration
  def change
      add_column :posts, :organization_id, :integer
  end
end
