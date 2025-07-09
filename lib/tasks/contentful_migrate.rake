module ContentfulMigrationHelper
  def self.flatten_hash(hash, prefix = "")
    hash.each_with_object({}) do |(key, value), result|
      current_key = prefix.empty? ? key.to_s : "#{prefix}.#{key}"
      if value.is_a?(Hash)
        result.merge!(flatten_hash(value, current_key))
      else
        result[current_key] = value.to_s
      end
    end
  end
end

namespace :contentful do
  desc "Migrate translations to Contentful"
  task migrate: :environment do
    require "net/http"
    require "uri"
    require "json"

    space_id = ENV["CONTENTFUL_SPACE_ID"]
    token = ENV["CONTENTFUL_MANAGEMENT_TOKEN"]

    # Loading translations
    yaml_content = YAML.load_file("config/locales/en.yml")
    translations = yaml_content["en"]

    flat_translations = ContentfulMigrationHelper.flatten_hash(translations)

    flat_translations.each do |key, value|
      # Create entry using direct HTTP request
      uri = URI("https://api.contentful.com/spaces/#{space_id}/environments/master/entries")
      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{token}"
      request["Content-Type"] = "application/vnd.contentful.management.v1+json"
      request["X-Contentful-Content-Type"] = "translation"

      request.body = {
        fields: {
          key: { "en-US" => key },
          value: { "en-US" => value },
        },
      }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      if response.code == "201"
        entry_data = JSON.parse(response.body)
        entry_id = entry_data["sys"]["id"]
        version = entry_data["sys"]["version"]

        # Publish the entry
        publish_uri = URI("https://api.contentful.com/spaces/#{space_id}/environments/master/entries/#{entry_id}/published")
        publish_request = Net::HTTP::Put.new(publish_uri)
        publish_request["Authorization"] = "Bearer #{token}"
        publish_request["Content-Type"] = "application/vnd.contentful.management.v1+json"
        publish_request["X-Contentful-Version"] = version.to_s

        publish_response = Net::HTTP.start(publish_uri.hostname, publish_uri.port, use_ssl: true) do |http|
          http.request(publish_request)
        end

        if publish_response.code == "200"
          puts "Created and published the: #{key}"
        else
          puts "Failed to publish the '#{key}': #{publish_response.body}"
        end
      else
        puts "Failed to create the '#{key}': #{response.body}"
      end
      # Adding tiny delay between requests to Contentful API owing to the API rate-limits
      sleep(0.5)
    rescue StandardError => e
      puts "Error with '#{key}': #{e.message}"
    end

    puts "Migration completed successfully!"
  end
end
