source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 8.0.1"
gem "bootsnap", require: false
gem "cssbundling-rails"
gem "govuk-components"
gem "govuk_design_system_formbuilder"
gem "jsbundling-rails"
gem "pg", "~> 1.1"
gem "propshaft"
gem "puma", ">= 5.0"
gem "bundler", ">=2.6.2"
gem 'dotenv'
gem 'vcr'

# https://github.com/contentful/contentful.rb
# https://www.rubydoc.info/gems/contentful
gem "contentful"

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "rspec"
  gem "rspec-rails"
  gem "rubocop-govuk", require: false
  gem "rubocop-performance", require: false
end

group :development do
  gem "rladr"
end
