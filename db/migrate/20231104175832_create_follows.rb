class CreateFollows < ActiveRecord::Migration[6.1]
  def change
    create_table :follows do |t|
      t.datetime :follow_timestamp, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
  end
end
