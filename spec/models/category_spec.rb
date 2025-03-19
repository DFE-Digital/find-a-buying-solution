require "rails_helper"

RSpec.describe Category, :vcr, type: :model do
  describe "#initialize" do
    subject(:category) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "category",
        "fields.slug": "ict"
      ).first
    end

    it "sets the attributes" do
      expect(category).to have_attributes(
        id: be_present,
        title: be_present,
        description: be_present,
        slug: be_present,
        subcategories: be_an(Array)
      )
    end
  end

  describe "#to_param" do
    subject(:category) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "category",
        "fields.slug": "ict"
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

    it "fetches categories in alphabetical order" do
      categories = described_class.all
      expect(categories.map(&:title)).to eq(categories.map(&:title).sort_by(&:downcase))
    end
  end

  describe "solutions ordering" do
    subject(:category) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "category",
        "fields.slug": "ict",
        include: 1
      ).first
    end

    it "orders solutions alphabetically by title" do
      solution_titles = category.solutions.map(&:title)
      expect(solution_titles).to eq(solution_titles.sort)
    end
  end

  describe "#filtered_solutions" do
    subject(:category) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "category",
        "fields.slug": "ict",
        include: 2
      ).first
    end

    it "filters solutions by subcategory slugs" do
      subcategory_slugs = %w[hardware software]
      filtered = category.filtered_solutions(subcategory_slugs: subcategory_slugs)
      expected_solution_slugs = %w[it-hardware mfd-digi-transform g-cloud]

      expect(filtered).to be_an(Array)
      expect(filtered).to all(be_a(Solution))
      expect(filtered.map(&:slug)).to match_array(expected_solution_slugs)
    end

    it "returns all solutions when subcategory_slugs is nil" do
      expect(category.filtered_solutions(subcategory_slugs: nil).length).to eq(category.solutions.length)
    end

    it "returns all solutions when subcategory_slugs is empty" do
      expect(category.filtered_solutions(subcategory_slugs: []).length).to eq(category.solutions.length)
    end

    it "excludes solutions that don't match any of the specified subcategory slugs" do
      subcategory_slugs = %w[hardware]
      filtered = category.filtered_solutions(subcategory_slugs: subcategory_slugs)
      expect(filtered.map(&:slug)).not_to include("microsoft-shape-the-future")
    end
  end

  describe ".find_by_slug!" do
    it "fetches a category by its slug from Contentful" do
      category = described_class.find_by_slug!("ict")
      expect(category).to be_present
      expect(category).to be_a(described_class)
      expect(category.slug).to eq("ict")
    end

    it "raises ContentfulRecordNotFoundError if no category is found by the given slug" do
      expect { described_class.find_by_slug!("non-existent-slug") }.to raise_error(ContentfulRecordNotFoundError)
    end
  end

  describe "#subcategories" do
    subject(:category) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "category",
        "fields.slug": "ict",
        include: 2
      ).first
    end

    it "returns an array of Subcategory objects with correct titles" do
      expected_titles = ["Hardware", "Software", "Networking", "Audio and visual"]
      expect(category.subcategories).to all(be_a(Subcategory))
      expect(category.subcategories.map(&:title)).to match_array(expected_titles)
    end
  end

  describe ".search" do
    subject(:search) { described_class.search(query: query) }

    let(:query) { "catering" }

    it "returns categories matching the query" do
      expect(search).to all(be_a(described_class))
      expect(search.first).to have_attributes(
        id: be_present,
        title: be_present,
        description: be_present,
        slug: be_present
      )
    end
  end
end
