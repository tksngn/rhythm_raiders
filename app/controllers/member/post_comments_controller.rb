class Member::PostCommentsController < ApplicationController
  
  def create
    created_track = CreatedTrack.find(params[:created_track_id])
    comment = current_member.post_comments.new(post_comment_params)
    comment.created_track_id = created_track.id
    comment.save
    redirect_to member_created_tracks_path(created_track)
  end
  
  private
  
  def post_comment_params
    params.require(:post_comment).permit(:comment)
  end
end
