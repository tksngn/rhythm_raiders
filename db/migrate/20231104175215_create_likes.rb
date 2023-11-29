class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes do |t|
      t.references :member, null: false, foreign_key: true
      t.references :created_track, null: false, foreign_key: true
      t.datetime :like_timestamp, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
  end
end
