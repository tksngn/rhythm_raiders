class Admin::CommentsController < ApplicationController
  before_action :authenticate_admin!
  
  # 物理削除せず「運営による削除」フラグを立てる（跡に中立的な墓標を表示＝炎上防止）
  def destroy
    comment = PostComment.find(params[:id])
    comment.update(removed_by_admin: true)
    redirect_to admin_member_path(comment.member_id), notice: "コメントを削除しました（ガイドラインに基づく）。"
  end
end
