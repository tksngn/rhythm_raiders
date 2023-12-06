class Member::RelationshipsController < ApplicationController

  def create
    current_member.follow(params[:customer_id])
    redirect_to request.referer
  end

  def destroy
    current_member.unfollow(params[:customer_id])
    redirect_to request.referer
  end
end
