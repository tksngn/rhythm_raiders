class Admin::MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update]

  def index
    @members = Member.page(params[:page])
  end

  def show
    @member = Member.find_by(id: params[:id]) || Member.new
    if @member
      @track = @member.created_tracks.first
        if @track.nil?
        # トラックが存在しない場合の処理をここに書く
        # 例：リダイレクトする、エラーメッセージを表示する、など

        end
      @comments = @member.member_comments
    else
      # メンバーが見つからない場合の処理をここに書く
      # 例：リダイレクトする、エラーメッセージを表示する、など
    end
  end

  def edit

  end

  def update
    if @member.update(member_params)
      redirect_to admin_member_path(@member), notice: 'メンバー情報を更新しました。'
    else
      render :edit
    end
  end

  private

  def set_member
    @member = Member.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_members_path, alert: "指定されたメンバーは存在しません。"
  end

  def member_params
    params.require(:member).permit(:name, :email, :password, :password_confirmation)
  end
end
