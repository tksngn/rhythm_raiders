class Admin::MembersController < ApplicationController
  
  def index
    @members = Member.all
  end
end
