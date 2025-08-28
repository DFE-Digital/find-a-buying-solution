require_relative "../i18n/utils"
require_relative "../../app/helpers/contentful_helper"
require "yaml"

# Converts flattened keys into a nested hash and writes them to a YAML file
def write_flattened_translations_to_yml(translations, file_path)
  # Convert the flattened hash into a nested hash
  nested_translations = translations.each_with_object({}) do |(key, value), result|
    keys = key.split(".")
    leaf = keys.pop
    current = result

    keys.each do |k|
      current[k] ||= {}
      current = current[k]
    end

    current[leaf] = value
  end

  # Ensure to wrap in the root `en` namespace
  nested_translations = { "en" => nested_translations }

  # Write to the YAML file
  File.open(file_path, "w") do |f|
    f.write(nested_translations.to_yaml)
  end

  puts "Translations written to #{file_path}"
end

namespace :contentful do
  include ContentfulHelper

  desc "Download translations from Contentful and update en.yml"
  task contentful_to_en_translations_update: :environment do
    require "json"

    begin
      validate_environment_variables(%w[CONTENTFUL_SPACE_ID CONTENTFUL_MANAGEMENT_TOKEN])
      space_id = ENV["CONTENTFUL_SPACE_ID"]
      token = ENV["CONTENTFUL_MANAGEMENT_TOKEN"]

      # Fetch translations from Contentful
      puts "Fetching existing translations from Contentful..."
      contentful_entries = fetch_contentful_translations(space_id, token)
      contentful_translations = transform_contentful_translations(contentful_entries)

      # Load the existing en.yml
      en_yml_path = Rails.root.join("config/locales/en.yml")
      existing_translations = load_flattened_translations(en_yml_path)

      # Merge the translations
      merged_translations = existing_translations.merge(contentful_translations)
      puts "Merged translations, preparing to write to en.yml..."

      # Write the merged translations back to en.yml
      write_flattened_translations_to_yml(merged_translations, en_yml_path)
      puts "en.yml updated successfully!"
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end
  end
end
