class CreateMemberComments < ActiveRecord::Migration[6.1]
  def change
    create_table :member_comments do |t|
      t.string :comment_content, null: false
      t.integer :like_count, null: false

      t.timestamps
    end
  end
end
