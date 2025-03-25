class Page
  include ActiveModel::Model
  include HasRelatedContent

  attr_reader :id, :title, :body, :description, :slug

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @body = entry.fields[:body]
    @description = entry.fields[:description]
    @slug = entry.fields[:slug]
    super
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
