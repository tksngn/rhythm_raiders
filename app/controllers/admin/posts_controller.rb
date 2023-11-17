# app/controllers/admin/posts_controller.rb
class Admin::PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find_by(id: params[:id]) || Post.new
    unless @post
    flash[:alert] = "Post not found"
    redirect_to admin_posts_path
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to admin_posts_path
  end

  def suspend
    @post = Post.find_by(id: params[:id])
    if @post
    # ここで利用停止の処理を行います。
      render :suspend
    end
  end
end

