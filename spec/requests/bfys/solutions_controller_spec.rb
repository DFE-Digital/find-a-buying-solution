require "rails_helper"

RSpec.describe "Bfys::Solutions", :vcr, type: :request do
  describe "GET /bfys/solutions.json" do
    before do
      get "/bfys/solutions.json"
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "returns solutions as JSON" do
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end
end
