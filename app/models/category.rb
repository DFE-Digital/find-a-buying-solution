class Category
  include ActiveModel::Model
  include HasRelatedContent

  attr_reader :id, :title, :description, :slug, :subcategories

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @description = entry.fields[:description]
    @slug = entry.fields[:slug]
    @subcategories = entry.fields.fetch(:subcategories, []).map { Subcategory.new(it) }.sort_by(&:title)
    super
  end

  def solutions
    Solution.all(category_id: id)
  end

  def self.all
    ContentfulClient.entries(
      content_type: "category",
      select: "sys.id,fields.title,fields.description,fields.slug",
      order: "fields.title"
    ).map { new(it) }
  end

  def self.search(query: "")
    ContentfulClient.entries(
      content_type: "category",
      query: query,
      select: "sys.id,fields.title,fields.description,fields.slug"
    ).map { new(it) }
  end

  def to_param
    slug
  end

  def self.find_by_slug!(slug)
    entry = ContentfulClient.entries(
      content_type: "category",
      'fields.slug': slug
    ).first

    raise ContentfulRecordNotFoundError.new("Category not found", slug: slug) unless entry

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
