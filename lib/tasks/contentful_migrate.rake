require_relative "../i18n/utils"
require_relative "../../app/helpers/contentful_helper"

include ContentfulHelper

namespace :contentful do
  desc "Migrate translations to Contentful"
  task migrate: :environment do
    require "net/http"
    require "uri"
    require "json"

    begin
      validate_environment_variables(%w[CONTENTFUL_SPACE_ID CONTENTFUL_MANAGEMENT_TOKEN])
      space_id = ENV["CONTENTFUL_SPACE_ID"]
      token = ENV["CONTENTFUL_MANAGEMENT_TOKEN"]

      en_yml_path = Rails.root.join("config", "locales", "en.yml")
      flat_translations = load_flattened_translations(en_yml_path)

      flat_translations.each do |key, value|
        begin
          uri = URI("https://api.contentful.com/spaces/#{space_id}/environments/master/entries")
          headers = {
            "Authorization" => "Bearer #{token}",
            "Content-Type" => "application/vnd.contentful.management.v1+json",
            "X-Contentful-Content-Type" => "translation"
          }

          body = {
            fields: {
              key: { "en-US" => key },
              value: { "en-US" => value }
            }
          }.to_json

          response = send_request(uri, method: "POST", headers: headers, body: body)

          if response.code == "201"
            entry_data = JSON.parse(response.body)
            publish_entry(entry_data["sys"]["id"], entry_data["sys"]["version"], token, space_id)
          else
            puts "Failed to create translation: #{key}. Error: #{response.body}"
          end

          sleep(0.5)
        rescue StandardError => e
          puts "Error with '#{key}': #{e.message}"
        end
      end

      puts "Migration completed successfully!"
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end
  end
end