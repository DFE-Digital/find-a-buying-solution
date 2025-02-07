class Category
  include ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Serialization

  attr_reader :id, :title, :summary, :description, :slug

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @summary = entry.fields[:summary]
    @description = entry.fields[:description]
    @slug = entry.fields[:slug]
  end

  def self.all
    ContentfulClient.entries(content_type: "category")
      .map { |entry| new(entry) }
  end

  def to_param
    slug
  end

  def self.find_by_slug(slug)
    entry = ContentfulClient.entries(content_type: "category", 'fields.slug': slug, include: 2).first
    new(entry) if entry
  end

  def solutions
    ContentfulClient.entries(content_type: "solution", 'fields.category.sys.id': id)&.map do |solution|
      Solution.new(solution)
    end || []
  end
end
