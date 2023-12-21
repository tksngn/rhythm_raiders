class CreatePostComments < ActiveRecord::Migration[6.1]
  def change
    create_table :post_comments do |t|
      t.integer :member_id
      t.integer :created_track_id
      t.string :comment_content, null: false

      t.timestamps
    end
  end
end
