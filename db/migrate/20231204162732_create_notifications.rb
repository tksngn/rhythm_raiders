class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :subject, polymorphic: true
      t.references :member, foreign_key: true, null: false
      t.integer :follower_id
      t.integer :followed_id
      t.integer :action_type, null: false
      t.boolean :checked, default: false, null: false

      t.timestamps
    end
  end
end
