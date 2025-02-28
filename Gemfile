source "https://rubygems.org"
ruby file: ".tool-versions"

gem "bootsnap", require: false
gem "contentful"
gem "cssbundling-rails"
gem "dotenv"
gem "govuk-components"
gem "govuk_design_system_formbuilder"
gem "jsbundling-rails"
gem "kramdown"
gem "pg", "~> 1.1"
gem "propshaft"
gem "puma", ">= 5.0"
gem "rails", "~> 8.0.1"

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "i18n-tasks"
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
