Rails.configuration.to_prepare do
  configure_contentful
  refresh_contentful_cache if Rails.env.production? && defined?(Rails.cache)
end

private

def configure_contentful
  ContentfulClient.configure(
    space: ENV.fetch("CONTENTFUL_SPACE_ID") { "FAKE_SPACE_ID" },
    access_token: ENV.fetch("CONTENTFUL_ACCESS_TOKEN") { "FAKE_API_KEY" },
    environment: ENV.fetch("CONTENTFUL_ENVIRONMENT", "master")
  )
end

def refresh_contentful_cache
  Rails.logger.info "Refreshing Contentful translations cache..."

  begin
    Rails.cache.delete(I18n::Backend::Contentful::CACHE_KEY)
    cached_translations = fetch_and_unflatten_contentful_translations
    Rails.cache.write(
      I18n::Backend::Contentful::CACHE_KEY,
      cached_translations,
      expires_in: I18n::Backend::Contentful::CACHE_EXPIRY
    )
    Rails.logger.info "✓ Contentful translations cache has been refreshed!"
  rescue => e
    Rails.logger.error "Error refreshing Contentful translations: #{e.message}"
  end
end

def fetch_and_unflatten_contentful_translations
  contentful_client = Contentful::Client.new(
    space: ENV["CONTENTFUL_SPACE_ID"],
    access_token: ENV["CONTENTFUL_ACCESS_TOKEN"],
    environment: ENV["CONTENTFUL_ENVIRONMENT"] || "master"
  )

  entries = contentful_client.entries(
    content_type: "translation",
    limit: 1000
  )

  I18n::Utils.unflatten_translations(entries)
end