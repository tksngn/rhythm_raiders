class Member::NotificationsController < ApplicationController

  def index
    @notifications = current_member.notifications.order(created_at: :desc).page(params[:page])#.per(5)
    @notifications.where(checked: false).each do |notification|
      notification.update(checked: true)
    end
  end

  def destroy
    @notifications = current_member.notifications.destroy_all
    redirect_to notifications_path
  end
end
