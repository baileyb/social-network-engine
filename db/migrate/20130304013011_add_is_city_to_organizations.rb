class AddIsCityToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :is_city, :boolean
  end
end
