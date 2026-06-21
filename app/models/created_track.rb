class CreatedTrack < ApplicationRecord
  belongs_to :member
  validates :music_title, presence: true
  # validates :creater_name, presence: true
  validates :music_genre, presence: true
  validates :creater_word, presence: true

  has_many :likes, dependent: :destroy
  has_many :post_comments, dependent: :destroy

  # 音源は ActiveStorage(S3/Supabase or ローカル) で保存
  has_one_attached :music_file
  validate :music_file_required

  def music_file_required
    errors.add(:music_file, "を選択してください") unless music_file.attached?
  end

  def liked_by?(member)
    return false unless member
    # likes が preload 済みなら追加クエリなしで判定（一覧のN+1回避）
    if likes.loaded?
      likes.any? { |like| like.member_id == member.id }
    else
      likes.where(member_id: member.id).exists?
    end
  end

  # def member_tracks(member)
  # # ここで、memberは特定のMemberオブジェクトを指します
  # # Trackモデルが存在し、Memberとの間に適切な関連性が定義されていると仮定します
  # member.member_tracks
  # end

  # def get_created_track
  # # ここで、何らかの属性を返すコードを書きます
  # # 例えば、music_title属性を返す場合は以下のようになります：
  # self.music_title
  # end

end

