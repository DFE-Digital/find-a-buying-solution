VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock

  config.filter_sensitive_data("<API_KEY>") do |interaction|
    interaction.request.headers["Authorization"]&.first
  end
end
