namespace :contentful do
  desc "Delete translations from Contentful"
  task en_to_contentful_translations_delete: :environment do
    space_id = ENV["CONTENTFUL_SPACE_ID"]
    token = ENV["CONTENTFUL_MANAGEMENT_TOKEN"]

    # Fetching local translation entries from en.yml
    en_yml_path = Rails.root.join("config/locales/en.yml")
    local_keys = load_flattened_translations(en_yml_path).keys

    client = Contentful::Management::Client.new(token)
    space = client.spaces.find(space_id)
    environment = space.environments.find("master")

    # Fetching translation entries from Contentful
    contentful_translations = environment.entries.all(content_type: "translation")
    contentful_translations_keys = contentful_translations.map { |x| x.fields[:key] }

    puts "Fetching existing translations from Contentful..."
    contentful_entries = ContentfulHelper.fetch_contentful_translations(space_id, token)
    puts "Fetched Contentful entries: #{contentful_entries.map(&:fields).inspect}"

    # Listing translations to delete
    translations_to_delete = contentful_translations_keys - local_keys
    if translations_to_delete.present?
      puts "The following translations will be deleted from Contentful:"
      puts translations_to_delete
    else
      puts "No translationsto delete!"
    end

    # Collecting the entries to delete
    delete_entries = translations_to_delete.map { |delete_key|
      contentful_translations.find { |entry| entry.fields[:key] == delete_key }
    }.compact

    # Proceeding to unpublish and then deleting each marked entry in Contentful
    delete_entries.each do |entry|
      if entry.published?
        entry.unpublish
        puts "Unpublished entry with key: #{entry.fields[:key]}..."
      end

      entry.destroy!
      puts "Deleted entry with key: #{entry.fields[:key]}..."
    rescue Contentful::Management::Error => e
      puts "Failed to delete entry with key: #{entry.fields[:key]}. Error: #{e.message}"
    end
  rescue StandardError => e
    puts "An error occurred: #{e.message}"
  end
end
