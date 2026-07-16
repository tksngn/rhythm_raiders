class AddMusicVideoUrlToCreatedTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :created_tracks, :music_video_url, :string
  end
end
