require "rails_helper"

RSpec.describe "Pages", :vcr, type: :request do
  describe "GET /pages/:slug" do
    before do
      get page_path("dynamic-purchasing-systems")
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "displays the page title" do
      expect(response.body).to include("Dynamic purchasing systems")
    end

    it "displays related content section" do
      expect(response.body).to include("Related content")
      expect(response.body).to match(%r{<a[^>]*>Framework agreements</a>})
      expect(response.body).to match(%r{<a[^>]*>Find a DFE-approved buying solution</a>})
    end
  end

  context "when page has no related content" do
    before do
      get page_path("cookies")
    end

    it "does not display related content section" do
      expect(response.body).not_to include("Related content")
    end
  end
end
