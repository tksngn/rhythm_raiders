class Comment < ApplicationRecord

  belongs_to :member
  belongs_to :post_comment

  before_save :set_posted_member_name

  has_one :notification, as: :subject, dependent: :destroy

  after_create_commit :create_notifications

  private

  def set_posted_member_name
    self.posted_member_name = self.member.name
  end

  def create_notifications
    Notification.create(subject: self, member_id: post_comment.member.id)
  end
end