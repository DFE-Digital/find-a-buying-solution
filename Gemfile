source "https://rubygems.org"
ruby file: ".tool-versions"

gem "bootsnap", require: false
gem "breadcrumbs_on_rails"
gem "contentful"
gem "contentful-management", require: false
gem "cssbundling-rails"
gem "csv", require: false
gem "dfe-analytics", github: "DFE-Digital/dfe-analytics", tag: "v1.15.6"
gem "dotenv"
gem "govuk-components"
gem "govuk_design_system_formbuilder"
gem "jsbundling-rails"
gem "kramdown"
gem "propshaft"
gem "puma", ">= 5.0"
gem "rack-attack", "~> 6.7"
gem "rails", "~> 8.0.2"
gem "rollbar"
gem "sidekiq", "~> 8.0"

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
