class Page
  include ActiveModel::Model

  attr_reader :id, :title, :body, :description, :slug, :sidebar, :related_content

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @body = entry.fields[:body]
    @description = entry.fields[:description]
    @slug = entry.fields[:slug]
    @sidebar = entry.fields[:sidebar]
    @related_content = entry.fields.fetch(:related_content, []).map { RelatedContent.new(it) }
  end

  def self.find_by_slug!(slug)
    entry = ContentfulClient.entries(
      content_type: "page",
      'fields.slug': slug
    ).first
    raise ContentfulRecordNotFoundError, "Page: '#{slug}' not found" unless entry

    new(entry)
  end
end
