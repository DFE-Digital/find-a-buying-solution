namespace :contentful do
  desc "Update en.yml with any translations that have changed in Contentful"
  task contentful_to_en_translations_update: :environment do
    require "yaml"

    begin
      validate_environment_variables(%w[CONTENTFUL_SPACE_ID CONTENTFUL_MANAGEMENT_TOKEN]) # Validates ENV vars
      space_id = ENV["CONTENTFUL_SPACE_ID"]
      token = ENV["CONTENTFUL_MANAGEMENT_TOKEN"]

      en_yml_path = Rails.root.join("config", "locales", "en.yml")
      backup_path = Rails.root.join("config", "locales", "en_backup.yml")

      puts "YAML file path: #{en_yml_path}"

      # Loading current translations
      puts "Loading current translations from en.yml..."
      flat_local_translations = load_flattened_translations(en_yml_path)
      puts "Loaded #{flat_local_translations.size} translations."

      # Fetching translations from Contentful
      puts "Fetching translations from Contentful..."
      contentful_entries = fetch_contentful_translations(space_id, token)
      puts "Fetched #{contentful_entries.size} entries from Contentful."

      # Transforming to an usable format
      contentful_translations = transform_contentful_translations(contentful_entries)
      puts "Transformed Contentful translations: #{contentful_translations.inspect}"

      # Comparing and updating
      puts "Comparing Contentful with local translations..."
      updated_translations = flat_local_translations.dup
      contentful_translations.each do |key, value|
        if flat_local_translations[key] != value
          puts "Updating key: #{key} | Value: #{value}"
          updated_translations[key] = value
        end
      end

      if updated_translations == flat_local_translations
        puts "No changes detected; en.yml is already up-to-date."
        return
      end

      # Backing-up existing en.yml
      FileUtils.cp(en_yml_path, backup_path)
      puts "Backup created at #{backup_path}"

      # De-normalizing and writing back to YAML file
      begin
        puts "De-normalizing the translations ..." + updated_translations.inspect
        structured_translations = I18n::Utils.convert_to_nested_translations(updated_translations)

        puts "Writing the updated translations to en.yml..."
        File.open(en_yml_path, "w") do |file|
          # Ensure keys are strings before writing to YAML
          file.write({ "en" => structured_translations }.to_yaml)
        end

        puts "en.yml successfully updated!"
      rescue StandardError => e
        puts "Error during unflattening or writing YAML: #{e.message}"
        FileUtils.cp(backup_path, en_yml_path) # Restore backup on failure
        puts "Restored backup from #{backup_path}"
      end
    rescue StandardError => e
      puts "An error occurred during task execution: #{e.message}"
    end
  end
end