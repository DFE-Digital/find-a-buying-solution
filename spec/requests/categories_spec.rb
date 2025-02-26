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

  describe "GET /categories/:slug with subcategory filters" do
    around do |example|
      VCR.use_cassette("contentful/category_with_subcategories") { example.run }
    end

    context "with empty subcategory_slugs parameter" do
      before do
        get category_path("ict-and-computer-software", subcategory_slugs: [])
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "displays all solutions in the category" do
        expect(response.body).to include("IT Hardware framework")
        expect(response.body).to include("Everything ICT framework")
      end

      it "displays the correct results count text" do
        expect(response.body).to include("5 results")
      end
    end

    context "with specific subcategory_slugs parameters" do
      before do
        get category_path("ict-and-computer-software", subcategory_slugs: %w[hardware])
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "only displays solutions with matching subcategories" do
        expect(response.body).to include("IT Hardware framework")
        expect(response.body).not_to include("Cloud Services framework")
      end

      it "displays the correct results count text" do
        expect(response.body).to include("1 result")
      end
    end

    context "when form is submitted with selected subcategories" do
      before do
        get category_path("ict-and-computer-software", subcategory_slugs: %w[hardware software])
      end

      it "keeps the checkboxes selected after form submission" do
        expect(response.body).to include('value="hardware" checked')
        expect(response.body).to include('value="software" checked')
        expect(response.body).not_to include('value="networking" checked')
      end

      it "displays the correct results count text" do
        expect(response.body).to include("2 results")
      end
    end
  end
end
