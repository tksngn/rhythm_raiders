class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "member"
  belongs_to :followed, class_name: "member"
end
