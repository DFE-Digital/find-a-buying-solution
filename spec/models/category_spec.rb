require "rails_helper"

RSpec.describe Category, :vcr, type: :model do
  describe "#initialize" do
    subject(:category) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "category",
        "fields.slug": "ict-and-computer-software",
      ).first
    end

    it "sets the attributes" do
      expect(category).to have_attributes(
        id: be_present,
        title: be_present,
        summary: be_present,
        description: be_present,
        slug: be_present,
        solutions: be_an(Array),
        subcategories: be_an(Array)
      )
    end
  end

  describe "#to_param" do
    subject(:category) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "category",
        "fields.slug": "ict-and-computer-software",
      ).first
    end

    it "returns the slug" do
      expect(category.to_param).to eq entry.fields[:slug]
    end
  end

  describe ".all" do
    it "fetches categories from Contentful" do
      categories = described_class.all
      expect(categories).to be_present
      expect(categories).to be_a(Array)
      expect(categories).to all(be_a(described_class))
    end
  end

  describe ".find_by_slug" do
    it "fetches a category by its slug from Contentful" do
      category = described_class.find_by_slug("ict-and-computer-software")
      expect(category).to be_present
      expect(category).to be_a(described_class)
      expect(category.slug).to eq("ict-and-computer-software")
    end

    it "raises ContentfulRecordNotFoundError if no category is found by the given slug" do
      expect { described_class.find_by_slug("non-existent-slug") }.to raise_error(ContentfulRecordNotFoundError)
    end
  end

  describe "#subcategories" do
    subject(:category) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "category",
        "fields.slug": "ict-and-computer-software",
        include: 2,
      ).first
    end

    it "returns an array of Subcategory objects with correct titles" do
      expected_titles = ["Hardware", "Software", "Networking", "Audio and visual"]
      expect(category.subcategories).to all(be_a(Subcategory))
      expect(category.subcategories.map(&:title)).to match_array(expected_titles)
    end
  end
end
