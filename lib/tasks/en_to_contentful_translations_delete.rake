namespace :contentful do
  desc "List and/or delete any translations that are in Contentful but not in en.yml"
  task en_to_contentful_translations_delete: :environment do
    begin
      validate_environment_variables(%w[CONTENTFUL_SPACE_ID CONTENTFUL_MANAGEMENT_TOKEN])
      space_id = ENV["CONTENTFUL_SPACE_ID"]
      token = ENV["CONTENTFUL_MANAGEMENT_TOKEN"]

      en_yml_path = Rails.root.join("config", "locales", "en.yml")
      local_keys = load_flattened_translations(en_yml_path).keys

      # Fetch translations in Contentful
      contentful_entries = fetch_contentful_translations(space_id, token)
      contentful_translations = transform_contentful_translations(contentful_entries)

      # List translations to delete
      translations_to_delete = contentful_translations.keys - local_keys

      # Delete the translations
      if translations_to_delete.any?
        puts "The following translations will be deleted from Contentful:"
        translations_to_delete.each do |key|
          entry = contentful_entries.find { |e| e["fields"]["key"]["en-US"] == key }
          entry_id = entry["sys"]["id"]

          puts "- Deleting key: #{key} (entry_id: #{entry_id})"

          # Unpublish and delete the entry in Contentful
          unpublish_contentful_entry(entry_id, space_id, token)
          delete_contentful_entry(entry_id, space_id, token)
        end

        puts "Deleted #{translations_to_delete.size} translation(s) from Contentful."
      else
        puts "No translations to delete. All Contentful translations match the en.yml file."
      end
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end
  end
end