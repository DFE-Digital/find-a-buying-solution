class Category
  include ActiveModel::Model

  attr_reader :id, :title, :summary, :description, :slug, :solutions, :subcategories

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @summary = entry.fields[:summary]
    @description = entry.fields[:description]
    @slug = entry.fields[:slug]
    @solutions = entry.fields.fetch(:solutions, []).map { Solution.new(it) }
    @subcategories = entry.fields.fetch(:subcategories, []).map { Subcategory.new(it) }
  end

  def self.all
    ContentfulClient.entries(
      content_type: "category",
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
end
