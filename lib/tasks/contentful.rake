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

  desc "Add provider initials to solutions (use with CONFIRM=yes to apply changes)"
  task add_provider_initials: :environment do
    json_data = JSON.parse(File.read("frameworks.json")).sort_by { |hash| hash["title"] }

    client = Contentful::Management::Client.new(ENV["CONTENTFUL_CMA_TOKEN"])
    space = client.spaces.find(ENV["CONTENTFUL_SPACE_ID"])
    environment = space.environments.find("master")

    json_data.each do |item|
      environment.content_types.find("solution")
      entries = environment.entries.all(content_type: "solution", "fields.slug" => item["ref"])
      if (entry = entries&.first)
        entry.update(provider_initials: item["provider"]["initials"])
        entry.publish
        puts "Updated solution #{item['title']} ref: #{item['ref']}"
      else
        puts "No entry found for #{item['title']} ref: #{item['ref']}"
      end
    end
  end

  desc "Fetches all solutions and checks if their URLs are working"
  task check_solution_urls: :environment do
    puts "Fetching all solutions and checking URLs..."

    solutions = Solution.all

    if solutions.empty?
      puts "No solutions found."
    else
      solutions.each do |solution|
        if solution.url.blank?
          puts "Solution '#{solution.title}' (ID: #{solution.id}, Slug: #{solution.slug}) has no URL."
          next
        end

        begin
          uri = URI.parse(solution.url)
          response = Net::HTTP.get_response(uri)
          status_code = response.code.to_i

          unless (200..299).cover?(status_code) || (300..399).cover?(status_code)
            puts "  ERROR: Status #{status_code} for '#{solution.title}' (ID: #{solution.id}, Slug: #{solution.slug}, URL: #{solution.url})"
          end
        rescue SocketError => e
          puts "  ERROR: Could not connect to '#{solution.title}' (ID: #{solution.id}, Slug: #{solution.slug}, URL: #{solution.url}) (SocketError: #{e.message})"
        rescue URI::InvalidURIError => e
          puts "  ERROR: Invalid URL for '#{solution.title}' (ID: #{solution.id}, Slug: #{solution.slug}, URL: #{solution.url}) (URI::InvalidURIError: #{e.message})"
        rescue StandardError => e
          puts "  ERROR: An unexpected error occurred for '#{solution.title}' (ID: #{solution.id}, Slug: #{solution.slug}, URL: #{solution.url}) (#{e.class}: #{e.message})"
        end
      end
    end

    puts "URL check complete."
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
      provider_initials: item["provider"]["initials"],
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
      provider_initials: item["provider"]["initials"],
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
