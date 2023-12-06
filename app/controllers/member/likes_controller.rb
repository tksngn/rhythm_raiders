class Member::LikesController < ApplicationController

  def create
    @created_track = CreatedTrack.find(params[:created_track_id])

    ActiveRecord::Base.transaction do
      @like = Like.find_or_initialize_by(member_id: current_member.id, created_track_id: @created_track.id)
      if @like.persisted?
        @like.destroy!
      else
        unless @like.save
          render json: { error: @like.errors.full_messages }, status: :unprocessable_entity
          return
        end
      end
    end
  end

  def destroy
    created_track = CreatedTrack.find(params[:created_track_id])
    like = current_member.likes.find_by(created_track_id: created_track.id)
    like.destroy
    redirect_to member_created_tracks_path(created_track)
  end
end

