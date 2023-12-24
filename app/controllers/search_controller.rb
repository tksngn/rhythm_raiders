# app/controllers/search_controller.rb

class SearchController < ApplicationController
  def index
    keyword = params[:keyword]
    @results = if keyword.present?
                 CreatedTrack.joins(:member).where('music_title LIKE ? OR music_genre LIKE ? OR members.creater_name LIKE ?', "%#{keyword}%", "%#{keyword}%", "%#{keyword}%")
               else
                 []
               end
  end
end
