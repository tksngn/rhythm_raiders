# app/controllers/admin/posts_controller.rb
class Admin::PostsController < ApplicationController
  before_action :authenticate_admin!
  
  # NOTE: 現状 posts テーブルは存在しない（未完成機能）。テーブルが無い場合に
  #       Post.all 等で500にならないよう全アクションでガードする。
  before_action :require_posts_table

  def index
    @posts = Post.all
  end

  def show
    @post = Post.find_by(id: params[:id])
    redirect_to admin_posts_path, alert: "Post not found" unless @post
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to admin_members_path
  end

  def suspend
    @post = Post.find_by(id: params[:id])
    render :suspend if @post
  end

  def search
    @results = Post.where('music_title LIKE ? OR music_genre LIKE ? OR creater_name LIKE ?', "%#{params[:keyword]}%", "%#{params[:keyword]}%", "%#{params[:keyword]}%")
  end

  private

  def require_posts_table
    return if Post.table_exists?

    redirect_to admin_members_path, alert: "投稿管理機能は現在利用できません。"
  end
end

