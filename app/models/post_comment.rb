class PostComment < ApplicationRecord
  
  belongs_to :member
  belongs_to :created_track
  
end
