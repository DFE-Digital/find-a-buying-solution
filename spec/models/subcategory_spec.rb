require "rails_helper"

RSpec.describe Subcategory, type: :model do
  describe "#initialize" do
    subject(:subcategory) { described_class.new(entry) }

    let(:entry) do
      VCR.use_cassette("contentful/subcategory") do
        ContentfulClient.entries(
          content_type: "subcategory",
          "fields.slug": "hardware",
        ).first
      end
    end

    it "sets the attributes" do
      expect(subcategory.id).to be_present
      expect(subcategory.title).to be_present
      expect(subcategory.slug).to be_present
    end
  end
end
