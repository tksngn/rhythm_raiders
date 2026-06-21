class Member::LikesController < ApplicationController

  def create
    created_track = CreatedTrack.find(params[:created_track_id])
    # 二重いいね防止（既にあれば作らない）
    current_member.likes.find_or_create_by(created_track_id: created_track.id)
    redirect_back fallback_location: root_path
  end

  def destroy
    created_track = CreatedTrack.find(params[:created_track_id])
    # いいねが見つからない場合(二重クリック等)でも nil.destroy で落ちないようにする
    current_member.likes.find_by(created_track_id: created_track.id)&.destroy
    redirect_back fallback_location: root_path
  end
end

