class Member::CreatedTracksController < ApplicationController
  before_action :authenticate_member!
  before_action :set_own_created_track, only: %i[edit update destroy]

  def show
    @created_track = CreatedTrack.find(params[:id])
    @like = current_member && @created_track ? @created_track.likes.find_by(member_id: current_member.id) : nil
    @post_comment = PostComment.new

    # 追加
    @following_members = current_member.following_member
    @follower_members = current_member.follower_member
  end

  def index
    # TODO: 複数同じものが表示された場合、.distinctをつける
    # 配列時のKaminari
    # refs: https://stackoverflow.com/questions/37562514/kaminari-pagination-not-effecting-the-table
    @created_tracks = sorted_created_tracks
  end

  def new
    @created_track = CreatedTrack.new
    @member = current_member
  end

  def create
    @created_track = CreatedTrack.new(created_track_params.merge(:member_id => current_member.id))
    if @created_track.save
      redirect_to member_created_tracks_path , notice: 'Track was successfully created.'
    else
      @created_tracks = CreatedTrack.page(params[:page]).per(5)
      @member = current_member
      render :new
    end
  end

  # 投稿後にタイトル/ジャンル/Creator Word/AI動画URL を編集する画面
  def edit
  end

  def update
    # 添付を外すかどうかは update の前に読んでおく（update後だとparamsは変わらないが意図を明示）
    removals = %i[music_image music_video_file].select do |name|
      params.dig(:created_track, :"remove_#{name}") == "1"
    end

    if @created_track.update(track_edit_params)
      # 添付を外すのは更新が通ってから。先に purge すると、バリデーションで
      # 弾かれた時に添付だけ消える。新しいファイルが来ている時は差し替えを優先する。
      removals.each do |name|
        next if track_edit_params[name].present?

        @created_track.public_send(name).purge
      end
      redirect_to member_created_track_path(@created_track), notice: '楽曲情報を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @created_track.destroy!
    redirect_to mypage_member_customers_path, notice: '楽曲を削除しました。'
  end

  def guest_index
    @guest_member = Member.find_by(email: 'guest@example.com')
    @created_tracks = sorted_created_tracks
  end

  private

  # 他人の楽曲を編集・削除できないよう、必ず current_member の投稿から引く
  def set_own_created_track
    @created_track = current_member.created_tracks.find_by(id: params[:id])
    return if @created_track

    redirect_to member_created_tracks_path, alert: 'その楽曲を操作する権限がありません。'
  end

  # 一覧/ゲスト一覧の並び替え + N+1回避の eager load をまとめる。
  # 本番(PostgreSQL)・開発(SQLite)とも RANDOM() で動作する（MySQLのRAND()は使わない）。
  def sorted_created_tracks
    # サムネイル(music_image)とプレーヤー(music_file)は一覧で全件ぶん参照するため、
    # 添付とblobまで一緒に引く（引かないと1曲につき2クエリ増える）
    eager = [:member, :likes,
             { music_image_attachment: :blob },
             { music_file_attachment: :blob }]
    case params[:sort]
    when "good"
      Kaminari.paginate_array(
        CreatedTrack.left_outer_joins(:likes).group("created_tracks.id")
          .order(Arel.sql("count(likes.created_track_id) desc")).preload(eager)
      ).page(params[:page]).per(5)
    when "comment"
      Kaminari.paginate_array(
        CreatedTrack.left_outer_joins(:post_comments).group("created_tracks.id")
          .order(Arel.sql("count(post_comments.created_track_id) desc")).preload(eager)
      ).page(params[:page]).per(5)
    when "random"
      Kaminari.paginate_array(
        CreatedTrack.order(Arel.sql("RANDOM()")).preload(eager)
      ).page(params[:page]).per(5)
    else
      # NOTE: .page/.per はモデル直で呼ぶ必要がある（relation経由だとperが付かない）。
      #       eager load は後段の preload で付与する。
      CreatedTrack.page(params[:page]).per(5).preload(eager)
    end
  end

  def created_track_params
    params.require(:created_track).permit(:music_title, :music_genre, :creater_word, :music_file,
                                          :music_image, :music_video_file, :music_video_url)
  end

  # 編集画面で扱うのはテキスト項目とAI動画URLのみ。
  # music_file は差し替えを許さない（音源が変わると実質「別の曲」になり、
  # いいね・コメントが元の曲に紐づいたまま中身だけすり替わるため）。
  def track_edit_params
    params.require(:created_track).permit(:music_title, :music_genre, :creater_word,
                                          :music_image, :music_video_file, :music_video_url)
  end
end