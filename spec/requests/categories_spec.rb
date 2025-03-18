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
      expected_titles = ["Audit or consultancy services", "Banking and Loans", "Catering"]

      expected_titles.each do |title|
        expect(response.body).to include(title)
      end
    end

    it "displays category descriptions" do
      expected_descriptions = [
        "Buy professional services from DfE-approved suppliers",
        "Buy banking and financial services from DfE-approved suppliers",
        "Buy catering equipment, catering service or food supplies from DfE-approved suppliers",
      ]

      expected_descriptions.each do |description|
        expect(response.body).to include(description)
      end
    end
  end

  describe "GET /categories/:slug" do
    before do
      get category_path("ict")
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "displays the category title" do
      expect(response.body).to include("IT services")
    end

    it "displays the category description" do
      expect(response.body).to include("Buy IT and ICT equipment and services from DfE-approved suppliers")
    end

    it "displays solutions in the category" do
      expect(response.body).to include("IT Hardware")
      expect(response.body).to include("Everything ICT")
    end
  end

  describe "GET /categories/:slug with subcategory filters" do
    context "with empty subcategory_slugs parameter" do
      before do
        get category_path("ict", subcategory_slugs: [])
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "displays all solutions in the category" do
        expect(response.body).to include("IT Hardware")
        expect(response.body).to include("Everything ICT")
      end

      it "displays the correct results count text" do
        expect(response.body).to include("5 results")
      end
    end

    context "with specific subcategory_slugs parameters" do
      before do
        get category_path("ict", subcategory_slugs: %w[hardware])
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "only displays solutions with matching subcategories" do
        expect(response.body).to include("IT Hardware")
        expect(response.body).to include("Multifunctional devices and digital transformation solutions")
        expect(response.body).not_to include("G-Cloud 14")
      end

      it "displays the correct results count text" do
        expect(response.body).to include("2 results")
      end
    end

    context "when form is submitted with selected subcategories" do
      before do
        get category_path("ict", subcategory_slugs: %w[hardware software])
      end

      it "keeps the checkboxes selected after form submission" do
        expect(response.body).to include('value="hardware" checked')
        expect(response.body).to include('value="software" checked')
        expect(response.body).not_to include('value="networking" checked')
      end

      it "displays the correct results count text" do
        expect(response.body).to include("3 results")
      end
    end
  end
end
