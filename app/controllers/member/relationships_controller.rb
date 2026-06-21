class Member::RelationshipsController < ApplicationController

  def create
    current_member.follow(params[:customer_id])
    redirect_back fallback_location: root_path
  end

  def destroy
    current_member.unfollow(params[:customer_id])
    redirect_back fallback_location: root_path
  end
end
