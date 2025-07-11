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
        # For date format lookups, use a specific approach
        if key.to_s == "date.formats.standard" || key.to_s == "formats.standard" && options[:scope] == %w[date]
          # Handling date formats with special care
          date_format = translations[:'en.date.formats.standard']
          if date_format.present?
            clean_format = date_format.gsub(/^"|"$/, "")
            Rails.logger.debug "Found date format: #{clean_format}"
            return clean_format
          end
        end

        # Handling relative keys (starting with ".")
        if key && key.is_a?(String) && key.start_with?(".")
          scope = options[:scope] || []
          Rails.logger.debug "Relative key: #{key}, scope: #{scope.inspect}"

          if scope.is_a?(Array) && scope.size > 0
            first_scope = scope.first.to_s
            if first_scope.include?("/")
              view_path = first_scope.split("/")
              key = "#{view_path.last}#{key}"
              scope = view_path[0..-2]
              Rails.logger.debug "Expanded key: #{key}, adjusted scope: #{scope.inspect}"
            end
          end
          options = options.merge(scope: scope)
        end

        # Normalizing the key path
        split_keys = I18n.normalize_keys(locale, key, options[:scope], options[:separator])
        Rails.logger.debug "Split keys: #{split_keys.inspect}"

        # Trying direct lookup with the full key
        direct_key = key.to_s
        if options[:scope] && options[:scope].size > 0
          scope_parts = Array(options[:scope])
          direct_key = "#{scope_parts.join('.')}.#{key}" unless key.include?(".")
        end
        Rails.logger.debug "Trying direct key: #{direct_key}"

        # Checking direct key match first
        direct_val = translations[direct_key.to_sym]
        if direct_val.present?
          Rails.logger.debug "Found direct key match: #{direct_key} = #{direct_val}"
          return direct_val
        end

        if translations[locale]
          flat_key = split_keys[1..].join(".")
          Rails.logger.debug "Trying in locale namespace: #{locale}.#{flat_key}"

          val = translations.dig(locale, flat_key.to_sym)
          if val.present?
            Rails.logger.debug "Found in locale namespace: #{val}"
            return val
          end
        end

        lookup_key = split_keys.join(".")
        Rails.logger.debug "Trying lookup key: #{lookup_key}"
        lookup_val = translations[lookup_key.to_sym]
        if lookup_val.present?
          Rails.logger.debug "Found lookup key match: #{lookup_val}"
          return lookup_val
        end

        flat_key = split_keys[1..].join(".")
        val = translations[flat_key.to_sym] if flat_key.present?

        if val.present?
          Rails.logger.debug "Found flat key match: #{flat_key} = #{val}"
          return val
        end

        # If contentful translations not found then trying to use default locale
        if options[:fallback] && locale != I18n.default_locale
          Rails.logger.debug "Trying fallback to default locale: #{I18n.default_locale}"
          return translate(I18n.default_locale, key, options.merge(fallback: false))
        end

        Rails.logger.debug "No translation found for #{key}"
        nil
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
