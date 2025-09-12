class Offer
  include ActiveModel::Model
  include HasRelatedContent

  attr_reader :id, :title, :description,
              :slug, :url, :call_to_action,
              :image, :featured_on_homepage, :expiry

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @description = entry.fields[:description]
    @slug = entry.fields[:slug]
    @url = entry.fields[:url]
    @call_to_action = entry.fields[:call_to_action]
    @image = entry.fields[:image]
    @featured_on_homepage = entry.fields[:featured_on_homepage]
    @expiry = entry.fields[:expiry]
    super
  end

  def self.all
    params = {
      content_type: "offer",
      select: %w[
        sys.id
        fields.title
        fields.description
        fields.slug
        fields.url
        fields.call_to_action
        fields.image
        fields.featured_on_homepage
        fields.expiry
      ].join(","),
      order: "fields.title",
    }
    ContentfulClient.entries(params).map { new(it) }
  end

  def ==(other)
    super || other.instance_of?(self.class) && other.id == id
  end
end


