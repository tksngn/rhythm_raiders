class MusicSamplesController < ApplicationController

  def index
    @music_samples = MusicSample.all
  end

end
