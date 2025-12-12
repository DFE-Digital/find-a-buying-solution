source "https://rubygems.org"
ruby file: ".tool-versions"

gem "bootsnap", require: false
gem "breadcrumbs_on_rails"
gem "contentful"
gem "contentful-management", require: false
gem "cssbundling-rails"
gem "csv", require: false
gem "dfe-analytics", github: "DFE-Digital/dfe-analytics", tag: "v1.15.12"
gem "dotenv"
gem "govuk-components"
gem "govuk_design_system_formbuilder"
gem "i18n", "~> 1.14"
gem "jsbundling-rails"
gem "kramdown"
gem "opensearch-ruby"
gem "propshaft"
gem "puma", ">= 5.0"
gem "rack-attack", "~> 6.8"
gem "rails", "~> 8.1.1"
gem "redis", "~> 5.4", require: false
gem "redis-rails", require: false
gem "rollbar"
gem "sidekiq", "~> 8.1"

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "i18n-tasks"
  gem "l10nizer", require: false
  gem "rspec"
  gem "rspec-rails"
  gem "rubocop-govuk", require: false
  gem "rubocop-performance", require: false
  gem "vcr"
  gem "webmock"
end

group :development do
  gem "rladr"
end

group :test do
  gem "capybara"
end
