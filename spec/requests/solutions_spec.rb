require "rails_helper"

RSpec.describe "Solutions pages", :vcr, type: :request do
  describe "GET /solutions/:slug" do
    before do
      get solution_path("it-hardware")
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "displays the solution title" do
      expect(response.body).to include("IT Hardware")
    end

    it "displays the solution description" do
      expect(response.body).to include("A full range of IT hardware including new, refurbished, and remanufactured.")
    end

    it "displays key solution detail sections" do
      expect(response.body).to include("What it offers")
      expect(response.body).to include("Benefits")
    end

    it "displays the call to action button" do
      expect(response.body).to include('<a class="govuk-button" href="https://www.procurementservices.co.uk/our-solutions/frameworks/technology/it-hardware">Visit the IT Hardware website</a>')
    end
  end
end
