class Member::CreatedTracksController < ApplicationController
  before_action :authenticate_member!

  def show
    @created_track = CreatedTrack.find(params[:id])
    @like = current_member && @created_track ? @created_track.likes.find_by(member_id: current_member.id) : nil
    @post_comment = PostComment.new

    # 追加
    @following_members = current_member.following_member
    @follower_members = current_member.follower_member
  end

  def index
    # TODO: 複数同じものが表示された場合、.distinctをつける
    # 配列時のKaminari
    # refs: https://stackoverflow.com/questions/37562514/kaminari-pagination-not-effecting-the-table
    case params[:sort]
    when "good"
      @created_tracks = Kaminari.paginate_array(CreatedTrack.left_outer_joins(:likes).group(:id).order("count(likes.created_track_id) desc")).page(params[:page]).per(5)
    when "comment"
      @created_tracks = Kaminari.paginate_array(CreatedTrack.left_outer_joins(:post_comments).group(:id).order("count(post_comments.created_track_id) desc")).page(params[:page]).per(5)
    when "random"
      # SQLiteの場合は、RANDOM()だが、MySQLの場合は、RAND()である。
      # refs: https://www.javadrive.jp/ruby/if/index10.html
      # refs: https://qiita.com/mightysosuke/items/3903368006eebdf239be
      # refs: https://kemarii.com/blog/rails/rails-env-branch/
      method = Rails.env.production? ? "RAND()" : "RANDOM()" # 本番環境または開発環境によって条件分岐
      @created_tracks = Kaminari.paginate_array(CreatedTrack.order(method)).page(params[:page]).per(5)
    else
      @created_tracks = CreatedTrack.page(params[:page]).per(5)
    end
  end

  def new
    @created_track = CreatedTrack.new
    @member = current_member
  end

  def create
    @created_track = CreatedTrack.new(created_track_params.merge(:member_id => current_member.id))
    if @created_track.save
      redirect_to member_created_tracks_path , notice: 'Track was successfully created.'
    else
      @created_tracks = CreatedTrack.page(params[:page]).per(5)
      @member = current_member
      render :new
    end
  end

  def update
    @created_track = CreatedTrack.find(params[:id])
    if @created_track.update(created_track_params)
      redirect_to @created_track, notice: 'Track was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @created_track = CreatedTrack.find(params[:id])
    redirect_to root_path and return unless @created_track.member = current_member
    @created_track.destroy!
    redirect_to mypage_member_customers_path(current_member.id)
  end

  def guest_index
    @guest_member = Member.find_by(email: 'guest@example.com')
    # ゲストメンバーは楽曲を作成できないので、作成済みの楽曲を取得する
    # is_guestカラムは楽曲がゲストメンバーによって試聴されたかどうかを表す
    @created_tracks = CreatedTrack.where(is_public: true)
    # ページネーションを適用する
    case params[:sort]
    when "good"
      @created_tracks = Kaminari.paginate_array(CreatedTrack.left_outer_joins(:likes).group(:id).order("count(likes.created_track_id) desc")).page(params[:page]).per(5)
    when "comment"
      @created_tracks = Kaminari.paginate_array(CreatedTrack.left_outer_joins(:post_comments).group(:id).order("count(post_comments.created_track_id) desc")).page(params[:page]).per(5)
    when "random"
      # SQLiteの場合は、RANDOM()だが、MySQLの場合は、RAND()である。
      # refs: https://www.javadrive.jp/ruby/if/index10.html
      # refs: https://qiita.com/mightysosuke/items/3903368006eebdf239be
      # refs: https://kemarii.com/blog/rails/rails-env-branch/
      method = Rails.env.production? ? "RAND()" : "RANDOM()" # 本番環境または開発環境によって条件分岐
      @created_tracks = Kaminari.paginate_array(CreatedTrack.order(method)).page(params[:page]).per(5)
    else
      @created_tracks = CreatedTrack.page(params[:page]).per(5)
    end
  end

  private

  def created_track_params
    params.require(:created_track).permit(:music_title, :music_genre, :creater_word, :music_file)
  end
end