class Like < ApplicationRecord
  belongs_to :member
  belongs_to :created_track
  # belongs_to :post_like

  validates :member_id, uniqueness: {scope: :created_track_id}

  has_one :notification, as: :subject, dependent: :destroy

  after_create_commit :create_notifications

  private
  def create_notifications
    Notification.create(subject: self, member_id: self.created_track.member_id)
  end
end
