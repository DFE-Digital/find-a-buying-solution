require "active_support/core_ext/integer/time"
require_relative "../../app/models/contentful_client"
require_relative "../../lib/i18n/backend/contentful"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [:request_id]
  config.logger   = ActiveSupport::TaggedLogging.logger($stdout)

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  config.cache_store = :redis_cache_store,
                       {  namespace: "fabs_cache_store",
                          expires_in: I18n::Backend::Contentful::CACHE_EXPIRY }

  # Replace the default in-process and non-durable queuing backend for Active Job.
  # config.active_job.queue_adapter = :resque

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  heroku_domain = "#{ENV['HEROKU_APP_NAME']}.herokuapp.com" if ENV["HEROKU_APP_NAME"].present?
  config.hosts = [heroku_domain, ENV["APP_DOMAIN"], ENV["FAF_DOMAIN"]].reject(&:blank?)

  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  config.before_initialize do
    # Setting I18n backend with Contentful & YAML fallback and exception handler

    # Setting I18n backend with YAML and exception handler
    yaml_backend = I18n::Backend::Simple.new

    backend_chain =
      begin
        # Use Contentful with YAML fallback
        contentful_backend = I18n::Backend::Contentful.new
        Rails.logger.info "I18n: Using Contentful backend with YAML fallback"
        [contentful_backend, yaml_backend]
      rescue StandardError => e
        Rails.logger.warn "Failed to initialize Contentful I18n backend: #{e.message}. Falling back to YAML translations."
        [yaml_backend]
      end

    # Chained backend creation
    I18n.backend = I18n::Backend::Chain.new(*backend_chain)

    # Enable fallbacks
    require "i18n/backend/fallbacks"
    I18n::Backend::Simple.include(I18n::Backend::Fallbacks)

    # Configure en-only fallbacks
    I18n.default_locale = :en
    I18n.available_locales = [:en]
    I18n.fallbacks.map(en: [:en])

    # Logging which backends are active
    Rails.logger.info "I18n backends initialized: #{backend_chain.map(&:class).join(', ')}"
  end
end
