class Member::MemberTracksController < ApplicationController

  def new
    @member_track = MemberTrack.new
  end

  def edit
    @member_track = MemberTrack.find(params[:id])
  end

  def create
    @member_track = MemberTrack.new(member_track_params)
    if @member_track.save
      redirect_to @member_track
    else
      render :new
    end
  end

  def destroy
    @member_track = MemberTrack.find(params[:id])
    @member_track.destroy
    redirect_to member_tracks_path
  end

  private

  def member_track_params
    params.require(:member_track).permit(:attribute1, :attribute2)
  end
end

