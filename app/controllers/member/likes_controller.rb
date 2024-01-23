class Member::LikesController < ApplicationController

  def create
    created_track = CreatedTrack.find(params[:created_track_id])
    created_track.likes.create(member_id: current_member.id)
    redirect_to request.referer
  end

  def destroy
    created_track = CreatedTrack.find(params[:created_track_id])
    redirect_to root_path and return unless created_track.member = current_member
    current_member.likes.find_by(member_id: current_member.id, created_track_id: created_track.id).destroy
    redirect_to request.referer
  end
end

