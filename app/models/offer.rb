class Offer
  include ActiveModel::Model

  attr_reader :id, :title, :description, :call_to_action, :url, :image, :featured_on_homepage, :slug

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @description = entry.fields[:description]
    @call_to_action = entry.fields[:call_to_action]
    @url = entry.fields[:url]
    @slug = entry.fields[:slug]
    @image = entry.fields[:image]
    @featured_on_homepage = entry.fields[:featured_on_homepage]
  end

  def self.find_by_slug(slug)
    entry = ContentfulClient.entries(
      content_type: "offer",
      'fields.slug': slug,
      limit: 1
    ).first
    entry ? new(entry) : nil
  rescue ContentfulRecordNotFoundError => e
    Rollbar.error(e, slug: slug)
    nil
  end

  def self.all(offer_id: nil)
    params = {
      content_type: "offer",
      select: %w[sys.id
                 fields.title
                 fields.description
                 fields.url
                 fields.slug
                 fields.call_to_action
                 fields.image
                 fields.featured_on_homepage].join(","),
      order: "fields.title",
      "fields.offers.sys.id[in]": offer_id,
    }.compact
    ContentfulClient.entries(params).map { new(it) }
  end


end
