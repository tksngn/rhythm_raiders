class Member::LikesController < ApplicationController

  def create
    created_track = CreatedTrack.find(params[:created_track_id])
    like = current_member.likes.new(created_track_id: created_track.id)
    like.save
    redirect_to member_created_tracks_path(created_track)
  end

  def destroy
    created_track = CreatedTrack.find(params[:created_track_id])
    like = current_member.likes.find_by(created_track_id: created_track.id)
    like.destroy
    redirect_to member_created_tracks_path(created_track)
  end
end
