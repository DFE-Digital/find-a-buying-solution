require "vcr"
require "webmock/rspec"

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.filter_sensitive_data("<CONTENTFUL_ACCESS_TOKEN>") { ENV["CONTENTFUL_ACCESS_TOKEN"] }
  c.filter_sensitive_data("<CONTENTFUL_SPACE_ID>") { ENV["CONTENTFUL_SPACE_ID"] }
  c.filter_sensitive_data("<CONTENTFUL_ENTRY_ID>") { ENV["CONTENTFUL_ENTRY_ID"] }
end