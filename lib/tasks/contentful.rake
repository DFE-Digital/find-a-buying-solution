require "json"
require "contentful/management"
require "net/http"
require "uri"

# rubocop:disable Rails/SaveBang
namespace :contentful do
  desc "Promote content from master to a new date-based environment"
  task promote: :environment do
    SPACE_ID = ENV.fetch("CONTENTFUL_SPACE_ID")
    TOKEN = ENV.fetch("CONTENTFUL_CMA_TOKEN")
    ALIAS_ID = 'production'
    SOURCE_ENV = 'master'
    NEW_ENV = "prod-#{Time.now.strftime("%d-%m-%Y")}"

    # Get current production environment
    uri = URI("https://api.contentful.com/spaces/#{SPACE_ID}/environment_aliases/#{ALIAS_ID}")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{TOKEN}"
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    current_prod_env = JSON.parse(response.body)['environment']['sys']['id']

    client = Contentful::Management::Client.new(TOKEN)
    space = client.spaces.find(SPACE_ID)

    puts "Cloning #{SOURCE_ENV} → #{NEW_ENV}..."
    clone = space.environments.create(id: NEW_ENV, name: NEW_ENV, source_environment_id: SOURCE_ENV)
    puts "Environment created successfully"

    puts "Switching alias #{ALIAS_ID} → #{NEW_ENV}..."
    uri = URI("https://api.contentful.com/spaces/#{SPACE_ID}/environment_aliases/#{ALIAS_ID}")
    req = Net::HTTP::Put.new(uri)
    req['Authorization'] = "Bearer #{TOKEN}"
    req['Content-Type'] = 'application/vnd.contentful.management.v1+json'
    req['X-Contentful-Version'] = version.to_s
    req.body = {
      environment: {
        sys: {
          type: 'Link',
          linkType: 'Environment',
          id: NEW_ENV
        }
      }
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    puts "✅ Promotion complete: #{ALIAS_ID} now points to #{NEW_ENV}."

    # Delete old production environment
    puts "Deleting old production environment: #{current_prod_env}"
    delete_uri = URI("https://api.contentful.com/spaces/#{SPACE_ID}/environments/#{current_prod_env}")
    delete_req = Net::HTTP::Delete.new(delete_uri)
    delete_req['Authorization'] = "Bearer #{TOKEN}"
    Net::HTTP.start(delete_uri.hostname, delete_uri.port, use_ssl: true) do |http|
      http.request(delete_req)
    end
  end

  desc "Import Find a Framework data into Contentful"
  task import_faf_data: :environment do
    json_data = JSON.parse(File.read("frameworks.json")).sort_by { |hash| hash["title"] }

    client = Contentful::Management::Client.new(ENV["CONTENTFUL_CMA_TOKEN"])
    space = client.spaces.find(ENV["CONTENTFUL_SPACE_ID"])
    environment = space.environments.find("master")

    categories = create_categories(environment, json_data)
    json_data.each do |item|
      puts "solution #{item['title']}"
      category = categories[item["cat"]["ref"]]
      puts "Using category: #{category.id}"
      solution = create_solution(environment, item, category)
      puts "Created solution: #{solution.id}"
      category.update(solutions: (Array(category.solutions) + [solution]).uniq)
    rescue StandardError => e
      puts e
    end
  end
end

def unique_categories(json_data)
  json_data.map { it["cat"] }.uniq
end

def create_categories(environment, json_data)
  categories = {}
  unique_categories(json_data).each { |item| categories[item["ref"]] = create_category(environment, item) }
  categories
end

def create_solution(environment, item, category)
  puts "Starting solution #{item['title']}"
  solution_type = environment.content_types.find("solution")
  entries = environment.entries.all(content_type: "solution", "fields.slug" => item["ref"])
  entry = entries.first

  if entry
    puts "Updating existing solution"
    entry.update(
      title: item["title"],
      description: item["descr"],
      summary: item["body"],
      provider_name: item["provider"]["title"],
      url: item["url"],
      expiry: item["expiry"],
      categories: (Array(entry.categories) + [category]).uniq,
      _metadata: {
        tags: [{ sys: { type: "Link", linkType: "Tag", id: "faf" } }],
      }
    )
  else
    puts "Creating solutions: #{item['title']} with slug #{item['ref']} "
    entry = solution_type.entries.create(
      title: item["title"],
      description: item["descr"],
      summary: item["body"],
      slug: item["ref"],
      provider_name: item["provider"]["title"],
      url: item["url"],
      expiry: item["expiry"],
      categories: (Array(entry.categories) + [category]).uniq,
      _metadata: {
        tags: [{ sys: { type: "Link", linkType: "Tag", id: "faf" } }],
      }
    )
  end
  entry.publish
  entry
end

def create_category(environment, item)
  puts "category #{item['title']}"
  entries = environment.entries.all(content_type: "category", "fields.slug" => item["ref"])
  entry = entries.first

  if entry
    puts "Updating existing category"
    entry.update(title: item["title"],
                 _metadata: {
                   tags: [{ sys: { type: "Link", linkType: "Tag", id: "faf" } }],
                 })
  else
    puts "Creating category: #{item['title']} with slug #{item['ref']} "
    category_type = environment.content_types.find("category")
    entry = category_type.entries.create(
      title: item["title"],
      slug: item["ref"],
      description: "x",
      summary: "x",
      _metadata: {
        tags: [{ sys: { type: "Link", linkType: "Tag", id: "faf" } }],
      }
    )
  end
  entry.publish
  entry
end
# rubocop:enable Rails/SaveBang
