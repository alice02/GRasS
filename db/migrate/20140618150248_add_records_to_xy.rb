class AddRecordsToXy < ActiveRecord::Migration
  def change
    add_column :Records, :x, :float
    add_column :Records, :y, :float
  end
end
