class AddProfileToMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :profile, :string
  end
end
