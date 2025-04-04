require "json"
require "contentful/management"

# rubocop:disable Rails/SaveBang
namespace :contentful do
  desc "Import Find a Framework data into Contentful"
  task import_faf_data: :environment do
    json_data = JSON.parse(File.read("frameworks.json")).sort_by { |hash| hash["title"] }

    client = Contentful::Management::Client.new(ENV["CONTENTFUL_CMA_TOKEN"])
    space = client.spaces.find(ENV["CONTENTFUL_SPACE_ID"])
    environment = space.environments.find("master")

    categories = create_cats(environment, json_data)
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

def unique_cats(json_data)
  json_data.map { it["cat"] }.uniq
end

def create_cats(environment, json_data)
  categories = {}
  unique_cats(json_data).each { |item| categories[item["ref"]] = create_category(environment, item) }
  categories
end

def create_solution(environment, item, cat)
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
      categories: (Array(entry.categories) + [cat]).uniq,
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
      categories: (Array(entry.categories) + [cat]).uniq,
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
    cat_type = environment.content_types.find("category")
    entry = cat_type.entries.create(
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
