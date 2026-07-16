class CreatedTrack < ApplicationRecord
  # MV埋め込みで受け付けるホスト。ここに無いホストは iframe に流さない。
  YOUTUBE_HOSTS = %w[
    youtube.com www.youtube.com m.youtube.com
    youtu.be www.youtu.be
    youtube-nocookie.com www.youtube-nocookie.com
  ].freeze
  VIMEO_HOSTS = %w[vimeo.com www.vimeo.com player.vimeo.com].freeze

  belongs_to :member
  # 前後の空白を落とし、空欄は "" ではなく nil で保存する
  before_validation :normalize_music_video_url

  validates :music_title, presence: true
  # validates :creater_name, presence: true
  validates :music_genre, presence: true
  validates :creater_word, presence: true
  validate :music_video_url_must_be_embeddable

  has_many :likes, dependent: :destroy
  has_many :post_comments, dependent: :destroy

  # 音源は ActiveStorage(S3/Supabase or ローカル) で保存
  has_one_attached :music_file
  validate :music_file_required

  def music_file_required
    errors.add(:music_file, "を選択してください") unless music_file.attached?
  end

  # 投稿された動画URLを iframe の src に渡せる埋め込みURLへ変換する。
  # ホワイトリスト外のホスト・ID抽出不可なら nil を返す（= 埋め込まない）。
  # 戻り値は必ずこのメソッドが組み立てた文字列で、ユーザー入力をそのまま src に流さない。
  def music_video_embed_url
    uri = parsed_music_video_uri
    return nil unless uri

    host = uri.host.downcase
    if YOUTUBE_HOSTS.include?(host)
      id = youtube_video_id(uri, host)
      id && "https://www.youtube-nocookie.com/embed/#{id}"
    elsif VIMEO_HOSTS.include?(host)
      id = uri.path[%r{\A/(?:video/)?(\d+)\z}, 1]
      id && "https://player.vimeo.com/video/#{id}"
    end
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

  private

  def normalize_music_video_url
    self.music_video_url = music_video_url.to_s.strip.presence
  end

  def parsed_music_video_uri
    url = music_video_url.to_s.strip
    return nil if url.blank?

    uri = URI.parse(url)
    # http/https 以外（javascript: 等）と、ホスト無しを弾く
    return nil unless uri.is_a?(URI::HTTP) && uri.host.present?

    uri
  rescue URI::InvalidURIError
    nil
  end

  def youtube_video_id(uri, host)
    id =
      if host.end_with?("youtu.be")
        uri.path[%r{\A/([\w-]+)}, 1]
      elsif (matched = uri.path.match(%r{\A/(?:embed|shorts|v)/([\w-]+)}))
        matched[1]
      else
        param = Rack::Utils.parse_query(uri.query.to_s)["v"]
        param.is_a?(Array) ? param.first : param
      end
    id if id.to_s.match?(/\A[\w-]{11}\z/)
  end

  def music_video_url_must_be_embeddable
    return if music_video_url.blank?
    return if music_video_embed_url.present?

    errors.add(:music_video_url, "はYouTubeまたはVimeoの動画URLを入力してください")
  end
end

