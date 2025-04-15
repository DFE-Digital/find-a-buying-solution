Rails.configuration.to_prepare do
  ContentfulClient.configure(
    space: ENV.fetch("CONTENTFUL_SPACE_ID", "FAKE_SPACE_ID"),
    access_token: ENV.fetch("CONTENTFUL_ACCESS_TOKEN", "FAKE_API_KEY"),
    environment: ENV.fetch("CONTENTFUL_ENVIRONMENT", "master")
  )
end
