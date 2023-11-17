class AddActiveToMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :active, :boolean
  end
end
