require "rails_helper"

RSpec.describe "Categories page (homepage)", type: :request do
  around do |example|
    VCR.use_cassette("contentful/categories_all") { example.run }
  end

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
end
