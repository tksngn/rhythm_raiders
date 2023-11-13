class Admin::MembersController < ApplicationController

  def index
    @members = Member.page(params[:page])
  end
end
