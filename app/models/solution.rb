class Solution
  include ActiveModel::Model

  attr_reader :id, :title, :description, :summary, :slug, :provider_name, :url, :categories, :subcategories

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @summary = entry.fields[:summary]
    @description = entry.fields[:description]
    @slug = entry.fields[:slug]
    @provider_name = entry.fields[:provider_name]
    @url = entry.fields[:url]
    @categories = entry.fields[:categories]
    @subcategories = entry.fields[:subcategories]
  end

  def self.all(category_id: nil)
    params = {
      content_type: "solution",
      select: "sys.id, fields.title, fields.description, fields.slug, fields.categories, fields.subcategories",
      order: "fields.title",
      "fields.categories.sys.id[in]": category_id,
    }.compact
    ContentfulClient.entries(params).map { new(it) }
  end

  def self.search(query: "")
    ContentfulClient.entries(
      content_type: "solution",
      query: query,
      select: "sys.id,fields.title,fields.summary,fields.description,fields.slug"
    ).map { new(it) }
  end

  def self.find_by_slug!(slug)
    entry = ContentfulClient.entries(
      content_type: "solution",
      'fields.slug': slug,
      include: 1,
      select: %w[
        sys.id
        fields.title
        fields.description
        fields.summary
        fields.slug
        fields.provider_name
        fields.url
      ].join(",")
    ).find { |solution| solution.fields[:slug] == slug }
    raise ContentfulRecordNotFoundError, "Solution: '#{slug}' not found" unless entry

    new(entry)
  end

  def ==(other)
    super ||
      other.instance_of?(self.class) && other.id == id
  end
end
