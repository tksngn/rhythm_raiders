class RemoveMusicFileStringFromCreatedTracks < ActiveRecord::Migration[6.1]
  def up
    # ActiveStorage 移行に伴い不要になった旧 CarrierWave 用カラムを削除。
    # （これが NOT NULL のまま残っていて投稿時に制約違反していた）
    remove_column :created_tracks, :music_file if column_exists?(:created_tracks, :music_file)
  end

  def down
    add_column :created_tracks, :music_file, :string
  end
end
