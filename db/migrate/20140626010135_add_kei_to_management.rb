class AddKeiToManagement < ActiveRecord::Migration
  def change
    add_column :managements, :kei, :integer
  end
end
