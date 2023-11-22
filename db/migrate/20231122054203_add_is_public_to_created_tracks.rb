class AddIsPublicToCreatedTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :created_tracks, :is_public, :boolean, default: false
  end
end
