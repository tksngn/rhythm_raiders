class Member::CreatedTracksController < ApplicationController
  before_action :authenticate_member!

  def show
    @created_track = CreatedTrack.find(params[:id])
    @like = current_member ? @created_track.likes.find_by(member_id: current_member.id) : nil
    @post_comment = PostComment.new
  end

  def index
    @created_tracks = CreatedTrack.all
    @created_tracks = CreatedTrack.page(params[:page]).per(10)
  end

  def new
    @created_track = CreatedTrack.new
  end

  def create
    @created_track = CreatedTrack.new(created_track_params)
    if @created_track.save
      redirect_to @created_track, notice: 'Track was successfully created.'
    else
      render :new
    end
  end

  def guest_index
    @guest_member = Member.find_by(email: 'guest@example.com')
    # ゲストメンバーは楽曲を作成できないので、作成済みの楽曲を取得する
    # is_guestカラムは楽曲がゲストメンバーによって試聴されたかどうかを表す
    @created_tracks = CreatedTrack.where(is_public: true)
    # ページネーションを適用する
    @created_tracks = CreatedTrack.page(params[:page]).per(10)
  end

  private

  def created_track_params
    params.require(:created_track).permit(:music_title, :creater_name, :music_genre, :creater_word, :playback_duration, :music_file, :sample_music_file, :is_guest, :is_public)
  end
end