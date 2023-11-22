class Member::CustomersController < ApplicationController
  def show

  end

  def index

  end

  def mypage

  end

  def edit

  end

  def update

  end

  def guest_sign_in
    member = Member.find_or_initialize_by(email: 'guest@example.com')
    if member.new_record?
      member.password = SecureRandom.urlsafe_base64
      member.name = "Guest"
      member.creater_name = "Guest"
      member.phone_number = "000-0000-0000"
      member.gender = 0
      member.is_privacy_policy_accepted = 1
      member.is_active = true
      member.active = true
      member.save!
    end

    # ここで新しいトラックを作成します
    @created_track = CreatedTrack.new
    @created_track.music_title = "Fantasy Background Music"
    @created_track.creater_name = "Guest" # ここでcreater_name属性に値を設定します
    @created_track.music_genre = "Genre" # ここでmusic_genre属性に値を設定します
    @created_track.playback_duration = 30 # ここでplayback_duration属性に値を設定します
    @created_track.music_file = "/bgm_sounds/fantasy-background-music-110593.mp3" # 公開可能なディレクトリへのパス
    @created_track.save

    sign_in member
    redirect_to guest_index_member_created_tracks_path, notice: 'ゲストメンバーとしてログインしました。'
  end




  def unsubscribe

  end

  def withdraw

  end
end
