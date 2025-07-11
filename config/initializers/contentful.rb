Rails.configuration.to_prepare do
  configure_contentful
  refresh_contentful_cache if Rails.env.production? && defined?(Rails.cache)
end

private

# Configure the Contentful client and store it for reuse
def configure_contentful
  @contentful_client = Contentful::Client.new(
    space: ENV.fetch("CONTENTFUL_SPACE_ID") { "FAKE_SPACE_ID" },
    access_token: ENV.fetch("CONTENTFUL_ACCESS_TOKEN") { "FAKE_API_KEY" },
    environment: ENV.fetch("CONTENTFUL_ENVIRONMENT", "master")
  )
end

# Refresh the Contentful translations cache
def refresh_contentful_cache
  Rails.logger.info "Refreshing Contentful translations cache..."

  begin
    # Delete existing cache
    Rails.cache.delete(I18n::Backend::Contentful::CACHE_KEY)

    # Fetch and store translations
    cached_translations = fetch_and_unflatten_contentful_translations
    Rails.cache.write(
      I18n::Backend::Contentful::CACHE_KEY,
      cached_translations,
      expires_in: I18n::Backend::Contentful::CACHE_EXPIRY
    )

    Rails.logger.info "Contentful translations cache has been refreshed!"
  rescue => e
    Rails.logger.error "Error refreshing Contentful translations: #{e.message}"
  end
end

# Fetch Contentful translations using the preconfigured client
def fetch_and_unflatten_contentful_translations
  entries = @contentful_client.entries(
    content_type: "translation",
    limit: 1000
  )

  I18n::Utils.unflatten_translations(entries)
end