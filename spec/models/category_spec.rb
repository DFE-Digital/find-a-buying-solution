require "rails_helper"

RSpec.describe Category, type: :model do
  before do
    VCR.configure do |config|
      config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
      config.hook_into :webmock
    end
  end

  describe ".all" do
    it "fetches categories from Contentful" do
      VCR.use_cassette("contentful/categories_all") do
        categories = described_class.all
        expect(categories).to be_a(Contentful::Array)
      end
    end
  end
end
