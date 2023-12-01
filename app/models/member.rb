class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # validates :active, inclusion: { in: [true, false] }
  enum status: { active: 0, inactive: 1 }

  after_initialize :set_default_status, if: :new_record?

  has_one_attached :profile_image
  has_many :created_tracks, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  has_many :member_comments, dependent: :destroy
  has_many :posts, dependent: :destroy

  enum gender: { Male: 0, Non_binary: 1, Female: 2 }

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

  def withdrawn?
    !active
  end

  private

  def set_default_status
    self.status ||= :active
  end
end

