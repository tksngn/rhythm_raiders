class CreatePostLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :post_likes do |t|
      t.datetime :like_timestamp, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
  end
end
