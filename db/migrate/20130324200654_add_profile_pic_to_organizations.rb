class AddProfilePicToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :profile_pic, :string
  end
end
