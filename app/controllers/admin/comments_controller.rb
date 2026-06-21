class Admin::CommentsController < ApplicationController
  before_action :authenticate_admin!
  
  def destroy
    comment = PostComment.find(params[:id])
    member_id = comment.member_id
    comment.destroy
    redirect_to admin_member_path(member_id), notice: "コメントを削除しました。"
  end
end
