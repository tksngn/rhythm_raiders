class Member::PostCommentsController < ApplicationController

  def create
    @created_track = CreatedTrack.find(params[:created_track_id])
    @post_comment = current_member.post_comments.new(comment_content: post_comment_params[:comment])
    @post_comment.created_track_id = @created_track.id
    if @post_comment.save
      redirect_to member_created_track_path(@created_track)
    else
      @following_members = current_member.following_member
      @follower_members = current_member.follower_member
      render 'member/created_tracks/show'
    end
  end

  def destroy
    comment = current_member.post_comments.find(params[:id])
    redirect_to root_path and return unless comment.member = current_member
    comment.destroy!
    redirect_to member_created_track_path(comment.created_track_id)
  end

  private

  def post_comment_params
    params.require(:post_comment).permit(:comment)
  end
end
