class CreatedTrack < ApplicationRecord
  belongs_to :member
  validates :music_title, presence: true
  validates :creater_name, presence: true
  validates :music_genre, presence: true
  validates :creater_word, presence: true
  validates :playback_duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :music_file, presence: true

  # 他の属性（:music_title, :creater_name, :music_genre, :creater_word, :playback_duration, :music_file, :is_guest, :is_public）は既に存在すると仮定
  # 30秒の試聴用音楽ファイル
  attribute :sample_music_file

  has_many :likes, dependent: :destroy
  has_many :post_comments, dependent: :destroy

  def liked_by?(member)
    member && likes.where(member_id: member.id).exists?
  end

  def member_tracks(member)
  # ここで、memberは特定のMemberオブジェクトを指します
  # Trackモデルが存在し、Memberとの間に適切な関連性が定義されていると仮定します
  member.member_tracks
  end

  def get_created_track
  # ここで、何らかの属性を返すコードを書きます
  # 例えば、music_title属性を返す場合は以下のようになります：
  self.music_title
  end

end

