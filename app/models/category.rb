class Category
  include ActiveModel::Model

  attr_reader :id, :title, :summary, :description, :slug, :solutions, :subcategories

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @summary = entry.fields[:summary]
    @description = entry.fields[:description]
    @slug = entry.fields[:slug]
    @solutions = entry.fields.fetch(:solutions, []).map { Solution.new(it) }.sort_by(&:title)
    @subcategories = entry.fields.fetch(:subcategories, []).map { Subcategory.new(it) }
  end

  def self.all
    ContentfulClient.entries(
      content_type: "category",
      select: "sys.id,fields.title,fields.summary,fields.slug",
      order: "fields.title"
    ).map { new(it) }
  end

  def self.search(query: "")
    ContentfulClient.entries(
      content_type: "category",
      query: query,
      select: "sys.id,fields.title,fields.summary,fields.slug"
    ).map { new(it) }
  end

  def to_param
    slug
  end

  def self.find_by_slug!(slug)
    entry = ContentfulClient.entries(
      content_type: "category",
      'fields.slug': slug,
      include: 1,
      select: "sys.id,fields.title,fields.summary,fields.description,fields.slug,fields.subcategories,fields.solutions"
    ).first
    raise ContentfulRecordNotFoundError, "Category: '#{slug}' not found" unless entry

    new(entry)
  end

  def filtered_solutions(subcategory_slugs: nil)
    return solutions if subcategory_slugs.blank?

    solutions.select do |solution|
      solution.subcategories&.any? do |subcat|
        subcategory_slugs.include?(subcat.fields[:slug])
      end
    end
  end
end
