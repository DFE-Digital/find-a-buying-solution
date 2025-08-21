# lib/tasks/contentful_sync.rake or a standalone script

desc "Syncs Contentful data to Elasticsearch"
task sync_contentful_to_es: :environment do
  puts "Starting Contentful to Elasticsearch sync..."

  # Create the index if it doesn't exist
  create_index("solution-data")
  entries = Solution.all

  # Prepare the bulk indexing actions
  bulk_actions = entries.map do |entry|
    unless entry.primary_category.nil?
      primary_category = {
        id: entry.primary_category.id,
        title: entry.primary_category.title,
        slug: entry.primary_category.slug,
      }
    end
    {
      index: {
        _index: "solution-data",
        _id: entry.id,
        data: {
          id: entry.id,
          title: entry.title,
          description: entry.description,
          summary: entry.summary,
          slug: entry.slug,
          provider_reference: entry.provider_reference,
          primary_category: primary_category,
        },
      },
    }
  end

  # Perform the bulk indexing
  elasticsearch_client.bulk(body: bulk_actions)
  puts "Successfully indexed #{entries.size} entries into Elasticsearch."
end

# Create the index and its mapping
# rubocop:disable Rails/SaveBang
def create_index(index_name)
  return if elasticsearch_client.indices.exists?(index: index_name)

  elasticsearch_client.indices.create(
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
end
# rubocop:enable Rails/SaveBang

def elasticsearch_client
  @elasticsearch_client ||= Elasticsearch::Client.new(url: ENV["ELASTICSEARCH_URL"],
                                                      api_key: ENV["ELASTICSEARCH_API_KEY"],
                                                      verify_elasticsearch_product: false)
end
