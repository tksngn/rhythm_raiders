class Member::PostsController < ApplicationController
  def index
    @posts = Post.all.page(params[:page]).per(5)
  end
end
