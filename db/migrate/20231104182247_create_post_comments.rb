class CreatePostComments < ActiveRecord::Migration[6.1]
  def change
    create_table :post_comments do |t|
      t.references :member, foreign_key: true
      t.references :created_track, foreign_key: true
      t.string :comment_content, null: false

      t.timestamps
    end
  end
end
