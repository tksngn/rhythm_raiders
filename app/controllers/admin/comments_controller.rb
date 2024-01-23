class Admin::CommentsController < ApplicationController
  before_action :authenticate_admin!
  
  def destroy
    comment = Comment.find(params[:id])
    comment.destroy
    redirect_to admin_member_path(comment.member_id)
  end
end
