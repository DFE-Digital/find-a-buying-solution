require_relative "../i18n/utils"
require_relative "../../app/helpers/contentful_helper"

namespace :contentful do
  desc "Upload newly created/updated translations from en.yml to Contentful and republish them"
  task en_to_contentful_translations_create_or_update: :environment do
    require "json"

    begin
      ContentfulHelper.validate_environment_variables(%w[CONTENTFUL_SPACE_ID CONTENTFUL_MANAGEMENT_TOKEN])
      space_id = ENV["CONTENTFUL_SPACE_ID"]
      token = ENV["CONTENTFUL_MANAGEMENT_TOKEN"]

      en_yml_path = Rails.root.join("config/locales/en.yml")
      flat_translations = ContentfulHelper.load_flattened_translations(en_yml_path)

      puts "Fetching existing translations from Contentful..."
      contentful_entries = ContentfulHelper.fetch_contentful_translations(space_id, token)
      contentful_translations = ContentfulHelper.transform_contentful_translations(contentful_entries)

      # Identifying updated translations
      new_translations = flat_translations.reject { |key, _| contentful_translations.key?(key) }
      updated_translations = flat_translations.select do |key, value|
        contentful_translations.key?(key) && contentful_translations[key] != value
      end

      puts "Found #{new_translations.size} new translations."
      puts "Found #{updated_translations.size} updated translations."

      new_translations.merge(updated_translations).each do |key, value|
        puts "Processing translation key: #{key}"

        entry = contentful_entries.find { |e| e["fields"]["key"]["en-US"] == key }
        if entry
          puts "Updating existing entry for key: #{key}"
        else
          puts "Creating new entry for key: #{key}"
        end

        begin
          ContentfulHelper.create_or_update_contentful_entry(key, value, entry, space_id, token)
        rescue StandardError => e
          puts "Failed to process entry for key: #{key}. Error: #{e.message}"
        end
      end

      puts "Translation upload completed successfully!"
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end
  end
end
