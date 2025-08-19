module ContentfulHelper
  # Load and flatten translations from a YAML file
  def load_flattened_translations(file_path)
    raise "Error: Translation file not found at #{file_path}" unless File.exist?(file_path)

    translations = YAML.load_file(file_path)
    raise "Error: No translations found in #{file_path}" if translations["en"].nil?

    I18n::Utils.flatten_translations(translations["en"])
  end

  # Helper to send HTTP requests
  def send_request(uri, method:, headers: {}, body: nil)
    request_class = case method.upcase
                    when "GET" then Net::HTTP::Get
                    when "POST" then Net::HTTP::Post
                    when "PUT" then Net::HTTP::Put
                    when "DELETE" then Net::HTTP::Delete
                    else
                      raise "Invalid HTTP method: #{method}"
                    end

    request = request_class.new(uri)
    headers.each { |key, value| request[key] = value }
    request.body = body if body

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  end

  # Publishes an entry in Contentful
  def publish_entry(entry_id, version, token, space_id)
    uri = URI("https://api.contentful.com/spaces/#{space_id}/environments/master/entries/#{entry_id}/published")
    headers = {
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/vnd.contentful.management.v1+json",
      "X-Contentful-Version" => version.to_s
    }

    response = send_request(uri, method: "PUT", headers: headers)
    if response.code.to_i == 200
      puts "Published entry: #{entry_id}"
    else
      puts "Failed to publish entry #{entry_id}. Error: #{response.body}"
    end
  end

  # Validates required environment variables
  def validate_environment_variables(required_vars)
    missing_vars = required_vars.select { |var| ENV[var].nil? }
    raise "Error: Missing environment variables: #{missing_vars.join(', ')}" if missing_vars.any?
  end

  # Fetch translations from Contentful and parse the response
  def fetch_contentful_translations(space_id, token)
    uri = URI("https://api.contentful.com/spaces/#{space_id}/environments/master/entries?content_type=translation")
    headers = { "Authorization" => "Bearer #{token}" }

    response = send_request(uri, method: "GET", headers: headers)
    raise "Error fetching translations from Contentful: #{response.body}" if response.code != "200"

    parsed_data = JSON.parse(response.body)

    # Debug entire data structure
    puts "Full response body:"
    puts parsed_data.inspect

    entries = parsed_data["items"]
    puts "Fetched entries (first 5):"
    entries.first(5).each_with_index { |entry, index| puts "Entry #{index + 1}: #{entry.inspect}" }

    entries
  end

  # Converts Contentful entries into a flat key-value hash
  def transform_contentful_translations(entries)
    entries.each_with_object({}) do |entry, hash|
      # Skip entries that are not hashes
      unless entry.is_a?(Hash)
        puts "Skipping invalid entry (not a hash): #{entry.inspect}"
        next
      end

      # Skip entries without 'fields'
      unless entry["fields"].is_a?(Hash)
        puts "Skipping invalid entry (missing 'fields'): #{entry.inspect}"
        next
      end

      # Skip entries missing both 'key' and 'value'
      if entry["fields"]["key"].nil? || entry["fields"]["value"].nil?
        puts "Skipping entry (missing key/value pair): #{entry.inspect}"
        next
      end

      key = entry["fields"]["key"]["en-US"]
      value = entry["fields"]["value"]["en-US"]
      hash[key] = value
    end
  end

  # Unpublishes an entry in Contentful
  def unpublish_contentful_entry(entry_id, space_id, token)
    uri = URI("https://api.contentful.com/spaces/#{space_id}/environments/master/entries/#{entry_id}/published")
    headers = { "Authorization" => "Bearer #{token}" }
    send_request(uri, method: "DELETE", headers: headers)
  end

  # Deletes an entry in Contentful
  def delete_contentful_entry(entry_id, space_id, token)
    uri = URI("https://api.contentful.com/spaces/#{space_id}/environments/master/entries/#{entry_id}")
    headers = { "Authorization" => "Bearer #{token}" }
    send_request(uri, method: "DELETE", headers: headers)
  end

  # Creates or updates a Contentful entry
  def create_or_update_contentful_entry(key, value, entry, space_id, token)
    begin
      if entry
        # Update existing entry
        uri = URI("https://api.contentful.com/spaces/#{space_id}/environments/master/entries/#{entry['sys']['id']}")
        method = "PUT"
        headers = {
          "Authorization" => "Bearer #{token}",
          "X-Contentful-Version" => entry['sys']['version'].to_s # Ensure correct version
        }
        puts "Updating entry for key: #{key} with version #{entry['sys']['version']}"
      else
        # Create new entry
        uri = URI("https://api.contentful.com/spaces/#{space_id}/environments/master/entries")
        method = "POST"
        headers = {
          "Authorization" => "Bearer #{token}",
          "X-Contentful-Content-Type" => "translation"
        }
        puts "Creating new entry for key: #{key}"
      end

      body = {
        fields: {
          key: { "en-US" => key },
          value: { "en-US" => value }
        }
      }.to_json

      response = send_request(uri, method: method, headers: headers, body: body)

      if response.code.to_i.between?(200, 299)
        entry_data = JSON.parse(response.body)
        puts "Successfully processed key: #{key}. Contentful response code: #{response.code}"

        # Publish entry after creation or update
        publish_entry(entry_data["sys"]["id"], entry_data["sys"]["version"], token, space_id)
      else
        puts "Failed to process key: #{key}. Response code: #{response.code}, Error: #{response.body}"
      end
    rescue StandardError => e
      puts "Error while creating or updating entry for key: #{key}. Details: #{e.message}"
    end
  end
end