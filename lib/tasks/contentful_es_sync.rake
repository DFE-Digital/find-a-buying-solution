# lib/tasks/contentful_sync.rake or a standalone script

desc "Syncs Contentful data to Elasticsearch"
task sync_contentful_to_es: :environment do
  puts "Starting Contentful to Elasticsearch sync..."

  # Create the index if it doesn't exist
  create_index("solution-data")

  client = Contentful::Management::Client.new(ENV["CONTENTFUL_CMA_TOKEN"])
  space = client.spaces.find(ENV["CONTENTFUL_SPACE_ID"])
  environment = space.environments.find("master")

  # Fetch all solution entries of a specific content type
  entries = environment.entries.all(content_type: "solution")

  # Prepare the bulk indexing actions
  bulk_actions = entries.map do |entry|
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
        },
      },
    }
  end

  # Perform the bulk indexing
  ELASTICSEARCH_CLIENT.bulk(body: bulk_actions)
  puts "Successfully indexed #{entries.size} entries into Elasticsearch."
end
