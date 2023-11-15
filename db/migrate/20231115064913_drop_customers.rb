class DropCustomers < ActiveRecord::Migration[6.1]
  def up
    drop_table :customers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
