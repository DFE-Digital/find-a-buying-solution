require "rails_helper"

RSpec.describe Solution, :vcr, type: :model do
  describe "#initialize" do
    subject(:solution) { described_class.new(entry) }

    let(:entry) do
      ContentfulClient.entries(
        content_type: "solution",
        "fields.slug": "technology-products-and-associated-services"
      ).first
    end

    it "sets the attributes" do
      expect(solution).to have_attributes(
        id: be_present,
        title: be_present,
        summary: be_present,
        description: be_present,
        slug: be_present,
        suffix: be_present,
        provider_name: be_present
      )
    end
  end

  describe ".all" do
    subject(:solutions) { described_class.all }

    it "fetches solutions from Contentful" do
      expect(solutions).to be_present
      expect(solutions).to be_a(Array)
      expect(solutions).to all(be_a(described_class))
    end

    it "fetches solutions in alphabetical order" do
      expect(solutions.map(&:title)).to eq(solutions.map(&:title).sort_by(&:downcase))
    end

    context "when filtering by category_id" do
      let(:category) { Category.find_by_slug!("it") }
      let(:category_id) { category.id }
      let(:solutions) { described_class.all(category_id: category_id) }

      it "returns only solutions from the specified category" do
        solutions.each do |solution|
          solution_category_ids = solution.categories.map(&:id)
          expect(solution_category_ids).to include(category_id)
        end
      end
    end
  end

  describe ".search" do
    subject(:search) { described_class.search(query: query) }

    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("USE_OPENSEARCH", false).and_return(nil)
    end

    let(:query) { "technology" }

    it "returns solutions matching the query" do
      expect(search).to all(be_a(described_class))
      expect(search.first).to have_attributes(
        id: be_present,
        title: be_present,
        summary: be_present,
        description: be_present,
        slug: be_present
      )
    end
  end

  describe ".find_by_slug!" do
    subject(:solution) { described_class.find_by_slug!(slug) }

    context "when solution exists" do
      let(:slug) { "it-hardware" }

      it "returns the solution" do
        expect(solution).to be_a(described_class)
        expect(solution.slug).to eq(slug)
      end
    end

    context "when solution does not exist" do
      let(:slug) { "non-existent" }

      it "raises ContentfulRecordNotFoundError" do
        expect { solution }.to raise_error(ContentfulRecordNotFoundError, "Solution not found")
      end
    end
  end

  describe ".find_by_id!" do
    subject(:solution) { described_class.find_by_id!(id) }

    context "when solution exists" do
      let(:id) { "1cFyWcuXyiTWce11GytE0C" }

      it "returns the solution" do
        expect(solution).to be_a(described_class)
        expect(solution.id).to eq(id)
      end
    end

    context "when solution does not exist" do
      let(:id) { "non-existent" }

      it "raises ContentfulRecordNotFoundError" do
        expect { solution }.to raise_error(ContentfulRecordNotFoundError, "Solution not found")
      end
    end
  end
end
