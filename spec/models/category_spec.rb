require "rails_helper"

RSpec.describe Category, type: :model do
  describe "#initialize" do
    subject(:category) { described_class.new(entry) }

    let(:entry) do
      VCR.use_cassette("contentful/category") do
        ContentfulClient.entries(
          content_type: "category",
          "fields.slug": "ict-and-computer-software",
        ).first
      end
    end

    it "sets the attributes" do
      expect(category.id).to be_present
      expect(category.title).to be_present
      expect(category.summary).to be_present
      expect(category.description).to be_present
      expect(category.slug).to be_present
      expect(category.solutions).to be_an(Array)
      expect(category.subcategories).to be_an(Array)
    end
  end

  describe "#to_param" do
    subject(:category) { described_class.new(entry) }

    let(:entry) do
      VCR.use_cassette("contentful/category") do
        ContentfulClient.entries(
          content_type: "category",
          "fields.slug": "ict-and-computer-software",
        ).first
      end
    end

    it "returns the slug" do
      expect(category.to_param).to eq entry.fields[:slug]
    end
  end

  describe ".all" do
    it "fetches categories from Contentful" do
      VCR.use_cassette("contentful/categories_all") do
        categories = described_class.all
        expect(categories).to be_present
        expect(categories).to be_a(Array)
        expect(categories).to all(be_a(described_class))
      end
    end
  end

  describe ".find_by_slug" do
    it "fetches a category by its slug from Contentful" do
      VCR.use_cassette("contentful/category_by_slug") do
        category = described_class.find_by_slug("ict-and-computer-software")
        expect(category).to be_present
        expect(category).to be_a(described_class)
        expect(category.slug).to eq("ict-and-computer-software")
      end
    end

    it "raises ContentfulRecordNotFoundError if no category is found by the given slug" do
      VCR.use_cassette("contentful/category_by_slug_not_found") do
        expect { described_class.find_by_slug("non-existent-slug") }.to raise_error(ContentfulRecordNotFoundError)
      end
    end
  end

  describe "#subcategories" do
    subject(:category) { described_class.new(entry) }

    let(:entry) do
      VCR.use_cassette("contentful/category") do
        ContentfulClient.entries(
          content_type: "category",
          "fields.slug": "ict-and-computer-software",
          include: 2,
        ).first
      end
    end

    it "returns an array of Subcategory objects with correct titles" do
      expected_titles = ["Hardware", "Software", "Networking", "Audio and visual"]
      expect(category.subcategories).to all(be_a(Subcategory))
      expect(category.subcategories.map(&:title)).to match_array(expected_titles)
    end
  end
end
