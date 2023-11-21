class Member::PostsController < ApplicationController
  def index
    # 投稿を全て取得し、ページネーションを適用する
    # pageメソッドは表示するページ番号を指定する
    # perメソッドは1ページあたりの表示件数を指定する
    @posts = Post.all.page(params[:page]).per(10)
  end
end
