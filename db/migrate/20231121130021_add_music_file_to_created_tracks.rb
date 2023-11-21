class AddMusicFileToCreatedTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :created_tracks, :music_file, :string
  end
end
