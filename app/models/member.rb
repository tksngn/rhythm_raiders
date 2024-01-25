class Member < ApplicationRecord
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  enum status: { active: 0, inactive: 1 }

  has_one_attached :profile_image

  has_many :created_tracks, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :follower, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :followed, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :following_member, through: :follower, source: :followed # 自分がフォローしている人
  has_many :follower_member, through: :followed, source: :follower # 自分をフォローしている人

  enum gender: { Male: 0, Non_binary: 1, Female: 2 }

  validates :creater_name, presence: true

    # ユーザーをフォローする
  def follow(member_id)
    follower.create!(followed_id: member_id)
  end

  # ユーザーのフォローを外す
  def unfollow(member_id)
    follower.find_by(followed_id: member_id).destroy
  end

  # フォローしていればtrueを返す
  def following?(member)
    following_member.include?(member)
  end

  def get_created_track
    self.created_tracks
  end

  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |member|
    member.password = SecureRandom.urlsafe_base64
    member.confirmed_at = Time.now
    # 必要に応じて他の属性を設定
    end
  end

  def is_guest
    email == 'guest@example.com'
  end

  def get_profile_image(width, height)
    unless profile_image.attached?
      file_path = Rails.root.join('app/assets/images/no_image.jpg')
      profile_image.attach(io: File.open(file_path), filename: 'no_image.jpg', content_type: 'image/jpeg')
    end
    profile_image.variant(resize_to_limit: [width, height]).processed
  end

  def active_for_authentication?
    super && is_active?
  end

  def inactive_message
    is_active? ? super : :inactive_locked
  end
end

