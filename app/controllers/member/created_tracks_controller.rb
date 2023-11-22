# app/controllers/member/created_tracks_controller.rb
class Member::CreatedTracksController < ApplicationController

  def show
    @created_track = CreatedTrack.find(params[:id])
    @post_comment = PostComment.new
  end

  def index
    @created_track = CreatedTrack.new
    @created_track.music_title = "Fantasy Background Music"
    @created_track.creater_name = "Guest"
    @created_track.music_genre = "Genre"
    @created_track.creater_word = "ゲストさんようこそ！！"
    @created_track.playback_duration = 30
    @created_track.music_file = "/bgm_sounds/fantasy-background-music-110593.mp3"
    @created_track.is_guest = true
    @created_track.is_public = true
    @created_track.save
  end

  def guest_index
    # ゲストメンバーは楽曲を作成できないので、作成済みの楽曲を取得する
    # is_guestカラムは楽曲がゲストメンバーによって試聴されたかどうかを表す
    @created_tracks = CreatedTrack.where(is_public: true)
    # ページネーションを適用する
    #@created_tracks = @created_tracks.page(params[:page]).per(10) if @created_tracks.present?
  end
end
