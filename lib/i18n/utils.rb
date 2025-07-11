module I18n
  module Utils
    def self.flatten_translations(hash, prefix = "")
      hash.each_with_object({}) do |(key, value), result|
        current_key = prefix.empty? ? key.to_s : "#{prefix}.#{key}"
        if value.is_a?(Hash)
          result.merge!(flatten_translations(value, current_key))
        else
          result[current_key] = value.to_s
        end
      end
    end

    def self.unflatten_translations(entries)
      result = { en: {} }

      entries.each do |entry|
        next if entry.fields[:key].blank?

        key = entry.fields[:key].to_s
        value = entry.fields[:value].to_s

        # Special handling for date format strings - removing extra quotes
        value = value.gsub(/^"|"$/, "") if key.include?("date.formats")

        result[key.to_sym] = value
        parts = key.split(".")

        if parts.first == "en"
          # Removing 'en' if already prefixed with it
          build_nested_hash(result[:en], parts[1..], value)
        else
          build_nested_hash(result[:en], parts, value)
        end
      end

      # Ensuring date format is always available
      result[:en][:date] ||= {}
      result[:en][:date][:formats] ||= {}
      result[:en][:date][:formats][:standard] ||= "%d %B %Y"
      result[:'en.date.formats.standard'] ||= "%d %B %Y"

      result
    end

    def self.build_nested_hash(hash, key_parts, value)
      return if key_parts.empty?

      *path, final_key = key_parts
      current = hash

      path.each do |part|
        next if part.blank?

        current[part.to_sym] ||= {}
        current = current[part.to_sym]
      end

      current[final_key.to_sym] = value if final_key.present?
    end
  end
end
