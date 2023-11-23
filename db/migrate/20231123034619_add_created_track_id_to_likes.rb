class AddCreatedTrackIdToLikes < ActiveRecord::Migration[6.1]
  def change
    add_column :likes, :created_track_id, :integer
  end
end
