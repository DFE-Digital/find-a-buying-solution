require "rails_helper"

RSpec.describe Solution, type: :model do
  describe "#initialize" do
    subject(:solution) { described_class.new(entry) }

    let(:entry) do
      VCR.use_cassette("contentful/solution") do
        ContentfulClient.entries(
          content_type: "solution",
          "fields.slug": "it-hardware-framework",
        ).first
      end
    end

    it "sets the attributes" do
      expect(solution.id).to be_present
      expect(solution.title).to be_present
      expect(solution.summary).to be_present
      expect(solution.description).to be_present
      expect(solution.slug).to be_present
      expect(solution.provider_name).to be_present
      expect(solution.category).to be_present
    end
  end
end
