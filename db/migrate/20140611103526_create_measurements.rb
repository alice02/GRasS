class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.text :comment

      t.timestamps
    end
  end
end
