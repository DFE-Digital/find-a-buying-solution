require "net/http"
require "uri"

class ContentfulService
  def initialize(space_id:, token:, source_env: 'master', alias_id: 'production')
    @space_id = space_id
    @token = token
    @source_env = source_env
    @alias_id = alias_id
    @new_env = "production-#{Time.now.strftime("%Y-%m-%d-%H%M")}"
  end

  def promote
    current_prod_env = get_current_production_env
    clone_environment
    switch_alias
    delete_old_environment(current_prod_env)
  end

  private

  def get_current_production_env
    uri = URI("https://api.contentful.com/spaces/#{@space_id}/environment_aliases/#{@alias_id}")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{@token}"
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    JSON.parse(response.body)['environment']['sys']['id']
  end

  def clone_environment
    client = Contentful::Management::Client.new(@token)
    space = client.spaces.find(@space_id)
    puts "Cloning #{@source_env} → #{@new_env}..."
    space.environments.create(id: @new_env, name: @new_env, source_environment_id: @source_env)
    puts "Environment created successfully"
  end

  def switch_alias
    puts "Switching alias #{@alias_id} → #{@new_env}..."
    uri = URI("https://api.contentful.com/spaces/#{@space_id}/environment_aliases/#{@alias_id}")
    req = Net::HTTP::Put.new(uri)
    req['Authorization'] = "Bearer #{@token}"
    req['Content-Type'] = 'application/vnd.contentful.management.v1+json'
    req['X-Contentful-Version'] = get_alias_version
    req.body = {
      environment: {
        sys: {
          type: 'Link',
          linkType: 'Environment',
          id: @new_env
        }
      }
    }.to_json

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    puts "✅ Promotion complete: #{@alias_id} now points to #{@new_env}."
  end

  def get_alias_version
    uri = URI("https://api.contentful.com/spaces/#{@space_id}/environment_aliases/#{@alias_id}")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{@token}"
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    JSON.parse(response.body)['sys']['version']
  end

  def delete_old_environment(env_id)
    puts "Deleting old production environment: #{env_id}"
    delete_uri = URI("https://api.contentful.com/spaces/#{@space_id}/environments/#{env_id}")
    delete_req = Net::HTTP::Delete.new(delete_uri)
    delete_req['Authorization'] = "Bearer #{@token}"
    Net::HTTP.start(delete_uri.hostname, delete_uri.port, use_ssl: true) do |http|
      http.request(delete_req)
    end
  end
end 