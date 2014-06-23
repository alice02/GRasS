class AddMeasureidToManagement < ActiveRecord::Migration
  def change
    add_column :managements, :measurementid, :integer
  end
end
