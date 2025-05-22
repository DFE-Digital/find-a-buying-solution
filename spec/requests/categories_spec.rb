require "rails_helper"

RSpec.describe "Categories pages", :vcr, type: :request do
  describe "GET /" do
    before do
      get root_path
    end

    it "includes buying options section heading" do
      expect(response.body).to include("DfE-approved buying options by category")
    end

    it "displays category titles" do
      expected_titles = ["Banking and finance", "Catalogues", "Catering"]

      expected_titles.each do |title|
        expect(response.body).to include(title)
      end
    end

    it "displays category descriptions" do
      expected_descriptions = [
        "Buy professional services",
        "Buy financial services",
        "Buy food, drink and catering services",
      ]

      expected_descriptions.each do |description|
        expect(response.body).to include(description)
      end
    end

    it "includes the procurement support link with correct text" do
      expect(response.body)
        .to have_link(
          "I need something else",
          href: "https://www.get-help-buying-for-schools.service.gov.uk/procurement-support"
        )
    end
  end

  describe "GET /categories/:slug" do
    before do
      get category_path("it")
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "displays the category title" do
      expect(response.body).to include("IT")
    end

    it "displays the category description" do
      expect(response.body).to include("Buy IT and ICT equipment and services")
    end

    it "displays solutions in the category" do
      expect(response.body).to include("IT Hardware")
      expect(response.body).to include("Everything ICT")
    end

    it "displays related content" do
      expect(response.body).to include("Related content")
      expect(response.body).to have_link("Plan technology for your school")
    end
  end

  describe "GET /categories/:slug with no related content" do
    before do
      get category_path("risk-protection-and-insurance")
    end

    it "does not display related content" do
      expect(response.body).not_to include("Related content")
    end
  end

  describe "GET /categories/:slug with subcategory filters" do
    context "with empty subcategory_slugs parameter" do
      before do
        get category_path("it", subcategory_slugs: [])
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "displays all solutions in the category" do
        expect(response.body).to include("IT Hardware")
        expect(response.body).to include("Everything ICT")
      end

      it "displays the correct results count text" do
        expect(response.body).to include("20 results")
      end
    end

    context "with specific subcategory_slugs parameters" do
      before do
        get category_path("it", subcategory_slugs: %w[software])
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "only displays solutions with matching subcategories" do
        expect(response.body).to include("Corporate software and related products and services")
        expect(response.body).to include("Everything ICT")
        expect(response.body).not_to include("Cyber security services 4")
      end

      it "displays the correct results count text" do
        expect(response.body).to include("7 results")
      end
    end

    context "when form is submitted with selected subcategories" do
      before do
        get category_path("it", subcategory_slugs: %w[computers-and-other-hardware software])
      end

      it "keeps the checkboxes selected after form submission" do
        expect(response.body).to have_css("input[value='software'][checked]")
        expect(response.body).to have_css("input[value='cyber-security']:not([checked])")
      end

      it "displays the correct results count text" do
        expect(response.body).to include("7 results")
      end
    end
  end
end
