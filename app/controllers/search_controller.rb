# app/controllers/search_controller.rb

class SearchController < ApplicationController
  def index
    keyword = params[:keyword]
    @results = if keyword.present?
                 CreatedTrack.where('music_title LIKE ? OR music_genre LIKE ? OR creater_name LIKE ?', "%#{keyword}%", "%#{keyword}%", "%#{keyword}%")
               else
                 []
               end
  end
end
