require "rails_helper"

RSpec.describe "Search pages", :vcr, type: :request do
  describe "GET /search" do
    before do
      get search_path(query: "catering")
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "displays matching solutions" do
      expect(response.body).to include("Commercial catering equipment")
    end

    it "displays matching categories" do
      expect(response.body).to include("Catering goods and supplies")
    end

    it "hides search in header" do
      expect(response.body).not_to include("dfe-header__search")
    end
  end

  describe "GET /search with no results" do
    before do
      get search_path(query: "nonexistent")
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end
  end
end
