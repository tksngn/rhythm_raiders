class PostComment < ApplicationRecord

  belongs_to :member
  belongs_to :created_track

  validates :comment_content, presence: true

  has_one :notification, as: :subject, dependent: :destroy

  after_create_commit :create_notification

  private

  # コメントされたら楽曲の投稿者に通知（自分の投稿への自コメントは通知しない）
  def create_notification
    owner_id = created_track.member_id
    return if owner_id.blank? || owner_id == member_id

    Notification.create(subject: self, member_id: owner_id)
  end
end
