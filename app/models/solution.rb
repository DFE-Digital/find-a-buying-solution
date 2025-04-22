class Solution
  include ActiveModel::Model
  include HasRelatedContent

  attr_reader :id, :title, :description, :expiry, :summary, :slug, :provider_name, :url, :categories, :subcategories, :suffix, :call_to_action

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @summary = entry.fields[:summary]
    @description = entry.fields[:description]
    @slug = entry.fields[:slug]
    @provider_name = entry.fields[:provider_name]
    @url = entry.fields[:url]
    @expiry = entry.fields[:expiry]
    @call_to_action = entry.fields[:call_to_action]
    @categories = entry.fields[:categories]
    @subcategories = entry.fields[:subcategories]
    @suffix = entry.fields[:suffix]
    super
  end

  def self.all(category_id: nil)
    params = {
      content_type: "solution",
      select: "sys.id, fields.title, fields.description, fields.expiry, fields.slug, fields.categories, fields.subcategories, fields.suffix",
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
        fields.summary
        fields.description
        fields.slug
        fields.provider_name
        fields.url
        fields.expiry
        fields.call_to_action
        fields.suffix
        fields.related_content
      ].join(",")
    ).find { |solution| solution.fields[:slug] == slug }
    raise ContentfulRecordNotFoundError unless entry

    new(entry)
  end

  def ==(other)
    super ||
      other.instance_of?(self.class) && other.id == id
  end
end
