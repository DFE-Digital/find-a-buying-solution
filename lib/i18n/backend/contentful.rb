require_relative "../utils"

module I18n
  module Backend
    class Contentful
      include Base
      include Flatten

      CACHE_KEY = "contentful_translations".freeze
      CACHE_EXPIRY = 1.hour

      def initialize
        @translations = Concurrent::Hash.new
        ::ContentfulClient.configure(
          space: ENV["CONTENTFUL_SPACE_ID"],
          access_token: ENV["CONTENTFUL_ACCESS_TOKEN"],
          environment: ENV["CONTENTFUL_ENVIRONMENT"] || "master"
        )
        load_translations
      end

      def translations
        @translations || load_translations
      end

      def available_locales
        @available_locales || set_available_locales
      end

      def reload!
        load_translations
        true
      end

      def translate(locale, key, options = EMPTY_HASH)
        split_keys = I18n.normalize_keys(locale, key, options[:scope], options[:separator])

        if split_keys[0] == split_keys[1]
          split_keys.delete_at(1)
        end

        flat_key = split_keys[1..].join(".")
        val = translations.dig(split_keys[0], flat_key.to_sym)

        # If contentful translations not found then, yaml fallback is enabled
        if val.blank? && options[:fallback] && I18n.locale != I18n.default_locale
          val = translations[I18n.default_locale]&.[](flat_key.to_sym)
        end

        val.presence
      end

    private

      def load_translations
        # Fetch from Redis first
        cached_translations = Rails.cache.read(CACHE_KEY)

        if cached_translations.nil?
          # If not in cache, fetch from Contentful
          entries = ::ContentfulClient.entries(
            content_type: "translation",
            limit: 1000
          )

          cached_translations = I18n::Utils.unflatten_translations(entries)

          Rails.cache.write(CACHE_KEY, cached_translations, expires_in: CACHE_EXPIRY)
        end

        @translations = @translations.deep_merge(cached_translations)
        set_available_locales

        @translations
      end

      def set_available_locales
        @available_locales = translations.keys.map(&:to_sym)
      end
    end
  end
end
