class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.float :depth
      t.float :latitude
      t.float :longitude
      t.references :measurement, index: true

      t.timestamps
    end
  end
end
