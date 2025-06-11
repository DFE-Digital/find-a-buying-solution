require "rails_helper"

RSpec.describe "Search pages", :vcr, type: :request do
  include ActionView::Helpers::TranslationHelper

  describe "GET /search" do
    before do
      get search_path(query: "catering")
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "sets correct HTML title tag" do
      expect(response.body).to include("<title>Search results - catering - #{I18n.t('service.name')}</title>")
    end

    it "displays matching solutions" do
      expect(response.body).to include("Commercial catering equipment")
    end

    it "displays matching categories" do
      expect(response.body).to include("Catering")
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

  describe "search validation" do
    it "shows error for empty query" do
      get search_path(query: "")
      expect(response.body).to include(t("search.errors.empty"))
    end

    it "shows search page with error message for nil query" do
      get search_path
      expect(response).to be_successful
      expect(response.body).to include(t("search.errors.empty"))
    end

    it "shows error for query exceeding max length" do
      get search_path(query: "a" * 2001)
      expect(response.body).to include(t("search.errors.too_long"))
    end

    it "shows error for query exceeding max words" do
      get search_path(query: "word " * 26)
      expect(response.body).to include(t("search.errors.too_many_words"))
    end
  end
end
