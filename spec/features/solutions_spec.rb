require "rails_helper"

RSpec.describe "Solutions pages", :vcr, type: :feature do
  describe "GET /solutions/:slug" do
    before do
      visit solution_path("it-hardware")
    end

    it "returns a successful response" do
      expect(page).to have_http_status(:success)
    end

    it "displays the solution title" do
      expect(page).to have_content("IT Hardware")
    end

    it "displays the solution description" do
      expect(page).to have_content("A full range of IT hardware including new, refurbished, and remanufactured.")
    end

    it "displays key solution detail sections" do
      expect(page).to have_content("What it offers")
      expect(page).to have_content("Benefits")
    end

    it "displays related content section" do
      expect(page).to have_content("Related content")
    end

    it "displays the related content link" do
      expect(page).to have_link("Things to consider when buying IT")
    end
  end

  context "when solution has no related content" do
    before do
      visit solution_path("ict-procurement")
    end

    it "does not display related content section" do
      expect(page).not_to have_content("Related content")
    end
  end

  context "when displaying call to action button" do
    it "displays the default CTA text when no custom CTA is provided" do
      visit solution_path("it-hardware")
      expect(page).to have_link("Visit the IT Hardware website",
                                href: "https://www.procurementservices.co.uk/our-solutions/frameworks/technology/it-hardware",
                                class: "govuk-button")
    end

    it "displays the custom CTA text when provided" do
      visit solution_path("ict-procurement")
      expect(page).to have_link("Go to site",
                                href: "https://www.everythingict.org/",
                                class: "govuk-button")
    end

    it "includes the usability survey URL with service and return_url params" do
      visit solution_path("it-hardware")
      link = find("a.govuk-button[data-survey-url]", match: :first)
      survey_url = link["data-survey-url"]
      uri = URI.parse(survey_url)

      expect(uri.host).to eq("www.get-help-buying-for-schools.service.gov.uk")
      expect(survey_url).to include("service=find_a_buying_solution")
      expect(survey_url).to match(/return_url=[^&]+/)
    end
  end
end
