class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :subject, polymorphic: true
      t.integer :member_id, null: false
      t.boolean :checked, default: false, null: false

      t.timestamps
    end
  end
end
