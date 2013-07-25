class AddSeverityToStatus < ActiveRecord::Migration
  def change
    add_column :statuses, :severity, :integer
  end
end
