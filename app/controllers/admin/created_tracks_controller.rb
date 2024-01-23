class Admin::CreatedTracksController < ApplicationController
  before_action :authenticate_admin!
  
  def index
    @created_tracks = CreatedTrack.all
  end

  def destroy
    @created_track = CreatedTrack.find(params[:id])
    @created_track.destroy
    redirect_to admin_members_path
  end
end
