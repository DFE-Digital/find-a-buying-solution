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
      entries.each_with_object({}) do |entry, hash|
        next if entry.fields[:key].blank?

        key_parts = entry.fields[:key].split(".")
        next if key_parts.empty?

        locale = key_parts.shift.to_sym
        hash[locale] ||= {}

        build_nested_hash(hash[locale], key_parts, entry.fields[:value])
      end
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
