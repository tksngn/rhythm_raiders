class Admin::MembersController < ApplicationController
  before_action :set_member, only: [:show]

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


  private

  def set_member
    @member = Member.find_by(id: params[:id]) || Member.new

  end
end
