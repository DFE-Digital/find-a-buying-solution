# Configure Elasticsearch client
ELASTICSEARCH_CLIENT = Elasticsearch::Client.new(url: ENV["ELASTICSEARCH_URL"])

# Create the index and its mapping
# rubocop:disable Rails/SaveBang
def create_index(index_name)
  return if ELASTICSEARCH_CLIENT.indices.exists?(index: index_name)

  ELASTICSEARCH_CLIENT.indices.create(
    index: index_name,
    body: {
      settings: { number_of_shards: 1, number_of_replicas: 0 },
      mappings: {
        properties: {
          id: { type: "keyword" },
          title: { type: "text", analyzer: "english" },
          description: { type: "text", analyzer: "english" },
          summary: { type: "text", analyzer: "english" },
          slug: { type: "keyword" },
          provider_reference: { type: "keyword" },
        },
      },
    }
  )
  # rubocop:enable Rails/SaveBang
end
