class Member::CustomersController < ApplicationController

  def show
    @member = Member.find(params[:id])
    #@posts = @member.posts.page(params[:page]).reverse_order
    @following_members = @member.following_member
    @follower_members = @member.follower_member
    @created_track = @member.created_tracks.find_by(id: params[:created_track_id])
  end

  def index

  end

  def mypage
    @member = current_member
    # @created_track = current_member.created_tracks.first
    # @member_track = @created_track.member_tracks(@member).first if @created_track
    @following_members = @member.following_member
    @follower_members = @member.follower_member
  end

  def edit
    @member = Member.find(params[:id])
  end

  def update
    @member = Member.find(params[:id])
    @member.update(member_params)
    redirect_to mypage_member_customers_path(@member.id)
  end

  def follows
    member = Member.find(params[:id])
    @members = member.following_member.reverse_order
  end

  def followers
    member = Member.find(params[:id])
    @members = member.follower_member.reverse_order
  end

  def guest_sign_in
    member = Member.find_or_initialize_by(email: 'guest@example.com')
    if member.new_record?
      member.password = SecureRandom.urlsafe_base64
      member.name = "Kaiser Atrantiz"
      member.creater_name = "Resiak Z"
      member.phone_number = "000-0000-0000"
      member.gender = 0
      member.is_privacy_policy_accepted = 1
      member.is_active = true
      member.save!
    end

    sign_in member
    redirect_to guest_index_member_created_tracks_path, notice: 'ゲストメンバーとしてログインしました。'
  end

  def unsubscribe

  end

  def withdraw
    current_member.update(is_active: false)
    sign_out(current_member)
  end

  private

  def member_params
    params.require(:member).permit(:name, :email, :creater_name, :phone_number, :gender, :profile, :profile_image)
  end
end
