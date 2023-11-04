class CreateMemberTracks < ActiveRecord::Migration[6.1]
  def change
    create_table :member_tracks do |t|
      t.integer :playback_count, null: false
      t.boolean :favorite_flag, null: false
      t.datetime :playlist_addition_timestamp, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
  end
end
