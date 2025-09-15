VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.filter_sensitive_data("FAKE_API_KEY") { ENV["CONTENTFUL_ACCESS_TOKEN"] }
  config.filter_sensitive_data("FAKE_SPACE_ID") { ENV["CONTENTFUL_SPACE_ID"] }
  config.filter_sensitive_data("FAKE_OPENSEARCH_URL") { ENV["OPENSEARCH_URL"] }
  config.default_cassette_options = {
    record: :once,
  }
end

WebMock.disable_net_connect!
