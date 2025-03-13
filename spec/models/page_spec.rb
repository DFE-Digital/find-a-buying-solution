require "rails_helper"

RSpec.describe Page, :vcr, type: :model do
  describe "#initialize" do
    subject(:page) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "page",
        "fields.slug": "devtest"
      ).first
    end

    it "sets the attributes" do
      expect(page).to have_attributes(
        id: be_present,
        title: be_present,
        body: be_present,
        description: be_present,
        slug: be_present,
        sidebar: be_present
      )
    end
  end

  describe ".find_by_slug!" do
    subject(:find_page) { described_class.find_by_slug!(slug) }

    context "when page exists" do
      let(:slug) { "devtest" }

      it "returns the page" do
        expect(find_page).to be_a(described_class)
        expect(find_page.slug).to eq(slug)
      end
    end

    context "when page does not exist" do
      let(:slug) { "non-existent" }

      it "raises ContentfulRecordNotFoundError" do
        expect { find_page }.to raise_error(ContentfulRecordNotFoundError)
      end
    end
  end
end
