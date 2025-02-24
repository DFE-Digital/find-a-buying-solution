class Solution
  include ActiveModel::Model

  attr_reader :id, :title, :description, :summary, :slug, :provider_name, :url, :category

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @summary = entry.fields[:summary]
    @description = entry.fields[:description]
    @slug = entry.fields[:slug]
    @provider_name = entry.fields[:provider_name]
    @url = entry.fields[:url]
    @category = entry.fields[:category]
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
end
