class Page
  include ActiveModel::Model
  include HasRelatedContent

  attr_reader :id, :title, :body, :description, :slug, :parent

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @body = entry.fields[:body]
    @description = entry.fields[:description]
    @slug = entry.fields[:slug]
    parent_entry = entry.fields[:parent]
    @parent = build_parent_from_entry(parent_entry)
    super
  end

  def self.find_by_slug!(slug)
    entry = ContentfulClient.entries(
      content_type: "page",
      'fields.slug': slug,
      include: 4
    ).first
    raise ContentfulRecordNotFoundError.new("Page not found", slug: slug) unless entry

    new(entry)
  end

private

  def build_parent_from_entry(parent_entry)
    return nil unless parent_entry

    # Resolve Contentful::Link to a full entry if necessary
    entry = if parent_entry.respond_to?(:fields)
              parent_entry
            else
              ContentfulClient.entries('sys.id': parent_entry.id, include: 2).first
            end

    return nil unless entry

    content_type_id = entry.respond_to?(:content_type) ? entry.content_type&.id : nil

    case content_type_id
    when "category"
      Category.new(entry)
    when "page"
      Page.new(entry)
    end
  end
end
