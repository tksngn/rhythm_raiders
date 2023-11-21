class AddIsGuestToCreatedTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :created_tracks, :is_guest, :boolean
  end
end
