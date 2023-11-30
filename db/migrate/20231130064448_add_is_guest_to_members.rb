class AddIsGuestToMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :is_guest, :boolean, default: false
  end
end
