Rails.configuration.after_initialize do
  ContentfulClient.configure(
    space: ENV.fetch("CONTENTFUL_SPACE_ID", "fakespaceid"),
    access_token: ENV.fetch("CONTENTFUL_ACCESS_TOKEN", "fakeapikey"),
  )
end
