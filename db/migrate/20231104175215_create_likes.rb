class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes do |t|
      t.integer :member_id, null: false
      t.integer :created_track_id, null: false

      t.timestamps
    end
  end
end
