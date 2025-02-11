VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.filter_sensitive_data("FAKE_API_KEY") { ENV["CONTENTFUL_ACCESS_TOKEN"] }
  config.filter_sensitive_data("FAKE_SPACE_ID") { ENV["CONTENTFUL_SPACE_ID"] }
end
