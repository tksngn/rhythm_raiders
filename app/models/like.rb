class Like < ApplicationRecord
  belongs_to :member
  belongs_to :created_track
  belongs_to :post_like
  
  validates :member_id, uniqueness: {scope: :created_track_id}

  has_one :notification, as: :subject, dependent: :destroy

  after_create_commit :create_notifications

  private
  def create_notifications
    Notification.create(subject: self, end_member: post_like.end_member, action_type: :commented_to_own_post)
  end
end
