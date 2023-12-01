class AddCommentToPostComments < ActiveRecord::Migration[6.1]
  def change
    add_column :post_comments, :comment, :string
  end
end
