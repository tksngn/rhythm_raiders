class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "Member"
  belongs_to :followed, class_name: "Member"

  has_one :notification, as: :subject, dependent: :destroy

  after_create_commit :create_notifications

  private
  def create_notifications
    Notification.create(subject: self, member: followed, action_type: :followed_me)
  end
end
