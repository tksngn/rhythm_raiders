class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :active, inclusion: { in: [true, false] }

  has_one_attached :profile_image
  has_many :created_tracks, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  has_many :member_comments
  has_many :posts

  enum gender: { Male: 0, Non_binary: 1, Female: 2 }

  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |member|
    member.password = SecureRandom.urlsafe_base64
    member.confirmed_at = Time.now
    # 必要に応じて他の属性を設定
    end
  end

  def withdrawn?
    !active
  end
end

