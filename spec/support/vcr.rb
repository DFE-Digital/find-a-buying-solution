contentful_space_id = ENV.fetch("CONTENTFUL_SPACE_ID", "fakespaceid")
contentful_access_token = ENV.fetch("CONTENTFUL_ACCESS_TOKEN", "fakeapikey")

VCR.configure do |config|
  config.cassette_library_dir =
    File.expand_path("../fixtures/vcr_cassettes", __dir__)
  config.hook_into :webmock
  config.filter_sensitive_data("__SPACE_ID__") { contentful_space_id }
  config.filter_sensitive_data("__ACCESS_TOKEN__") { contentful_access_token }
end
