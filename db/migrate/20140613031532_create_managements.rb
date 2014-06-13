class CreateManagements < ActiveRecord::Migration
  def change
    create_table :managements do |t|
      t.boolean :state

      t.timestamps
    end
  end
end
