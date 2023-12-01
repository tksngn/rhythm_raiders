class RemoveCommentFromPostComments < ActiveRecord::Migration[6.1]
  def change
    remove_column :post_comments, :comment, :string
  end
end
