class CreateCreatedTracks < ActiveRecord::Migration[6.1]
  def change
    create_table :created_tracks do |t|
      t.references :member, foreign_key: true
      t.string :music_title, null: false
      t.string :creater_name, null: false
      t.string :music_genre, null: false
      t.string :creater_word, limit: 100
      t.integer :playback_duration, null: false
      t.datetime :release_date, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
  end
end
