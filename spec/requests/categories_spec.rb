require "rails_helper"

RSpec.describe "Categories pages", :vcr, type: :request do
  describe "GET /" do
    before do
      get root_path
    end

    it "includes buying options section heading" do
      expect(response.body).to include("Buying options, by category")
    end

    it "displays category titles" do
      expected_titles = ["Vehicle hire and purchase", "Furniture", "ICT and computer software"]

      expected_titles.each do |title|
        expect(response.body).to include(title)
      end
    end

    it "displays category summaries" do
      expected_summaries = ["Long-term catering contracts", "IT experts and technical advisors", "Lending or buying minibuses, coaches for school trips or other school transport"]

      expected_summaries.each do |summary|
        expect(response.body).to include(summary)
      end
    end
  end

  describe "GET /categories/:slug" do
    around do |example|
      VCR.use_cassette("contentful/category_by_slug") { example.run }
    end

    before do
      get category_path("ict-and-computer-software")
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "displays the category title" do
      expect(response.body).to include("ICT and computer software")
    end

    it "displays the category description" do
      expect(response.body).to include("Laptops, computers, tablets, software, broadband, Wi-Fi and cloud services")
    end

    it "displays solutions in the category" do
      expect(response.body).to include("IT Hardware framework")
      expect(response.body).to include("Everything ICT framework")
    end
  end
end
