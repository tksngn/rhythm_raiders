class CreatedTrack < ApplicationRecord
  belongs_to :member
  validates :music_title, presence: true
  validates :creater_name, presence: true
  validates :music_genre, presence: true
  validates :playback_duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :music_file, presence: true
end

