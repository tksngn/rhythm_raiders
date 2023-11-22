class Like < ApplicationRecord
  belongs_to :member
  belongs_to :created_track

  validates :member_id, uniquness: {scope: :created_track_id}
end
