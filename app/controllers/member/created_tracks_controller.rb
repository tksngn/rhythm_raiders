# app/controllers/member/created_tracks_controller.rb
class Member::CreatedTracksController < ApplicationController
  def guest_index
    # ゲストメンバーは楽曲を作成できないので、作成済みの楽曲を取得する
    # is_guestカラムは楽曲がゲストメンバーによって試聴されたかどうかを表す
    @created_tracks = CreatedTrack.where(is_guest: true)
    # ページネーションを適用する
    @created_tracks = @created_tracks.page(params[:page]).per(10) if @created_tracks.present?
  end
end
