class AddRemovedByAdminToPostComments < ActiveRecord::Migration[6.1]
  def change
    add_column :post_comments, :removed_by_admin, :boolean, default: false, null: false
  end
end
