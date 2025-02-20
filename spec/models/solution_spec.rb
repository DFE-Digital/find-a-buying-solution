require "rails_helper"

RSpec.describe Solution, :vcr, type: :model do
  describe "#initialize" do
    subject(:solution) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "solution",
        "fields.slug": "technology-products-and-associated-services-2"
      ).first
    end

    it "sets the attributes" do
      expect(solution).to have_attributes(
        id: be_present,
        title: be_present,
        summary: be_present,
        description: be_present,
        slug: be_present,
        provider_name: be_present
      )
    end
  end
end
