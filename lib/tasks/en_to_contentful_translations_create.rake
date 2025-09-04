namespace :contentful do
  desc "Upload translations from en.yml to Contentful"
  task en_to_contentful_translations_create: :environment do
    require "json"

    begin
      ContentfulHelper.validate_environment_variables(%w[CONTENTFUL_SPACE_ID CONTENTFUL_MANAGEMENT_TOKEN])
      space_id = ENV["CONTENTFUL_SPACE_ID"]
      token = ENV["CONTENTFUL_MANAGEMENT_TOKEN"]

      # Fetching local translation entries from en.yml
      en_yml_path = Rails.root.join("config/locales/en.yml")
      flat_translations = ContentfulHelper.load_flattened_translations(en_yml_path)

      puts "Fetching existing translations from Contentful..."
      contentful_entries = ContentfulHelper.fetch_contentful_translations(space_id, token)
      # puts "Fetched Contentful entries: #{contentful_entries.map(&:fields).inspect}"

      client = Contentful::Management::Client.new(token)
      space = client.spaces.find(space_id)
      space.environments.find("master")

      contentful_translations = ContentfulHelper.transform_contentful_translations(contentful_entries)
      # puts "Transformed Contentful translations: #{contentful_translations.inspect}"

      # Identify new translations
      new_translations = flat_translations.reject { |key, _| contentful_translations.key?(key) }

      puts "Found #{new_translations.size} new translations."

      new_translations.each do |key, value|
        ContentfulHelper.create_contentful_entry(key, value, space_id, token)
      rescue StandardError => e
        puts "Failed to process translation key: #{key}. Error: #{e.message}"
      end

      puts "Translation upload completed successfully!"
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end
  end
end
