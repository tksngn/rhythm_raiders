class Member::CreatedTracksController < ApplicationController
  before_action :authenticate_member!

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

  def update
    @created_track = CreatedTrack.find(params[:id])
    if @created_track.update(created_track_params)
      redirect_to @created_track, notice: 'Track was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @created_track = CreatedTrack.find(params[:id])
    redirect_to root_path and return unless @created_track.member = current_member
    @created_track.destroy!
    redirect_to mypage_member_customers_path(current_member.id)
  end

  def guest_index
    @guest_member = Member.find_by(email: 'guest@example.com')
    @created_tracks = sorted_created_tracks
  end

  private

  # 一覧/ゲスト一覧の並び替え + N+1回避の eager load をまとめる。
  # 本番(PostgreSQL)・開発(SQLite)とも RANDOM() で動作する（MySQLのRAND()は使わない）。
  def sorted_created_tracks
    eager = [:member, :likes]
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
    params.require(:created_track).permit(:music_title, :music_genre, :creater_word, :music_file)
  end
end