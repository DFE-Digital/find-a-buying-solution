ContentfulClient = Contentful::Client.new(
  space: ENV.fetch("CONTENTFUL_SPACE_ID", "FAKE_SPACE_ID"),
  access_token: ENV.fetch("CONTENTFUL_ACCESS_TOKEN", "<API_KEY>"),
  dynamic_entries: :auto,
)
