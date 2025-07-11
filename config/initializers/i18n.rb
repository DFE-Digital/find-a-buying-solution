Rails.application.config.before_initialize do
  require_relative "../../app/models/contentful_client"
  require_relative "../../lib/i18n/backend/contentful"

  # Default fallback backend - YAML file
  yaml_backend = I18n::Backend::Simple.new

  backend_chain = if Rails.env.development?
                    # Use only YAML backend in development
                    Rails.logger.info "I18n: Using YAML backend for development environment"
                    [yaml_backend]
                  else
                    begin
                      # Use Contentful with YAML fallback in other environments
                      contentful_backend = I18n::Backend::Contentful.new
                      Rails.logger.info "I18n: Using Contentful backend with YAML fallback"
                      [contentful_backend, yaml_backend]
                    rescue StandardError => e
                      Rails.logger.warn "Failed to initialize Contentful I18n backend: #{e.message}. Falling back to YAML translations."
                      [yaml_backend]
                    end
                  end

  # Chained backend creation
  chain = I18n::Backend::Chain.new(*backend_chain)
  I18n.backend = chain

  # Enable fallbacks
  require "i18n/backend/fallbacks"
  I18n::Backend::Simple.include(I18n::Backend::Fallbacks)

  # Configure en-only fallbacks
  if Rails.env.production?
    I18n.default_locale = :en
    I18n.available_locales = [:en]
    I18n.fallbacks.map(en: [:en])
  end

  if Rails.env.development?
    module I18n
      class CustomExceptionHandler < ExceptionHandler
        def call(exception, locale, key, options)
          if exception.is_a?(MissingTranslation) && key.to_s != "i18n.plural.rule"
            raise exception.to_exception
          else
            super
          end
        end
      end
    end

    I18n.exception_handler = I18n::CustomExceptionHandler.new
  end

  # Logging which backends are active
  Rails.logger.info "I18n backends initialized: #{backend_chain.map(&:class).join(', ')}"
end
