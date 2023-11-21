require 'rails_helper'

RSpec.describe "Member::CreatedTracks", type: :request do
  describe "GET /guest_index" do
    it "returns http success" do
      get "/member/created_tracks/guest_index"
      expect(response).to have_http_status(:success)
    end
  end

end
