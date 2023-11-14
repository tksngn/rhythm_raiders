class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :profile_image
  has_many :created_tracks
  has_many :member_comments

  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |member|
    member.password = SecureRandom.urlsafe_base64
    # 必要に応じて他の属性を設定
    end
  end
end

