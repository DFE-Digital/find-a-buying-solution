require "opensearch/transport"

class SolutionSearcher
  attr_reader :query, :client

  INDEX = "solution-data".freeze

  SolutionSearchResults = Struct.new(:id, :fields)
  PrimaryCategory = Struct.new(:id, :title, :slug)

  def initialize(query:)
    @client = SearchClient.instance
    @query = query
  end

  def search
    results = client.search(index: INDEX, body: search_body)["hits"]["hits"]
    return [] if results.empty?

    results.map do |result|
      fields = result["_source"].transform_keys(&:to_sym)
      primary_category = PrimaryCategory.new(id: fields[:primary_category]["id"],
                                             title: fields[:primary_category]["title"],
                                             slug: fields[:primary_category]["slug"])

      fields[:primary_category] = primary_category
      entry = SolutionSearchResults.new(id: fields[:id], fields: fields)
      Solution.new(entry)
    end
  end

private

  def search_body
    @search_body ||= {
      query: {
        multi_match: {
          query: query,
          fields: %w[title description summary slug provider_reference],
        },
      },
    }
  end
end
