class AddGeoToStatus < ActiveRecord::Migration
  def change
    add_column :statuses, :latitude, :float
    add_column :statuses, :longitude, :float
    add_column :statuses, :address, :string
  end
end
