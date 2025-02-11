require "rails_helper"

RSpec.describe Category, type: :model do
  describe ".all" do
    it "fetches categories from Contentful" do
      VCR.use_cassette("contentful/categories_all") do
        categories = described_class.all
        expect(categories).to be_present
        expect(categories).to be_a(Array)
        expect(categories).to all(be_a(Category))
      end
    end
  end
end
