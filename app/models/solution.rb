class Solution
  include ActiveModel::Model
  include HasRelatedContent

  attr_reader :id, :title, :description, :expiry, :summary,
              :slug, :provider_name, :provider_initials, :url,
              :categories, :subcategories, :suffix, :call_to_action,
              :primary_category, :buying_option_type, :provider_reference

  delegate :slug, to: :primary_category, prefix: true, allow_nil: true

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @summary = entry.fields[:summary]
    @description = entry.fields[:description]
    @slug = entry.fields[:slug]
    @provider_name = entry.fields[:provider_name]
    @provider_initials = entry.fields[:provider_initials]
    @url = entry.fields[:url]
    @expiry = entry.fields[:expiry]
    @suffix = entry.fields[:suffix]
    @call_to_action = entry.fields[:call_to_action]
    @categories = entry.fields[:categories]
    @subcategories = entry.fields[:subcategories]
    @primary_category = entry.fields[:primary_category]
    @buying_option_type = entry.fields[:buying_option_type]
    @provider_reference = entry.fields[:provider_reference]
    super
  end

  def self.all(category_id: nil)
    params = {
      content_type: "solution",
      select: %w[sys.id
                 fields.title
                 fields.description
                 fields.expiry
                 fields.slug
                 fields.categories
                 fields.subcategories
                 fields.url
                 fields.provider_name
                 fields.provider_initials
                 fields.related_content
                 fields.summary
                 fields.buying_option_type
                 fields.provider_reference
                 fields.primary_category].join(","),
      order: "fields.title",
      "fields.categories.sys.id[in]": category_id,
    }.compact
    ContentfulClient.entries(params).map { new(it) }
  end

  def self.search(query: "")
    # binding.break
    use_elastic_search = ENV.fetch("USE_ELASTIC_SEARCH", false)
    if use_elastic_search
      SolutionSearcher.new(query: query).search
    else
      ContentfulClient.entries(
        content_type: "solution",
        query: query,
        select: "sys.id,fields.title,fields.summary,fields.description,fields.slug,fields.provider_name,fields.buying_option_type,fields.provider_initials,fields.primary_category,fields.provider_reference"
      ).map { new(it) }
    end
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
        fields.expiry
        fields.related_content
        fields.summary
        fields.slug
        fields.suffix
        fields.provider_name
        fields.provider_initials
        fields.call_to_action
        fields.url
        fields.buying_option_type
        fields.provider_reference
        fields.primary_category
      ].join(",")
    ).find { |solution| solution.fields[:slug] == slug }

    raise ContentfulRecordNotFoundError.new("Solution not found", slug: slug) unless entry

    new(entry)
  end

  def self.find_by_id!(id)
    entry = ContentfulClient.entries(
      content_type: "solution",
      'sys.id': id,
      include: 1,
      select: %w[
        sys.id
        fields.title
        fields.description
        fields.expiry
        fields.related_content
        fields.summary
        fields.slug
        fields.suffix
        fields.provider_name
        fields.provider_initials
        fields.call_to_action
        fields.url
        fields.buying_option_type
        fields.provider_reference
        fields.primary_category
      ].join(",")
    ).find { |solution| solution.sys[:id] == id }

    raise ContentfulRecordNotFoundError.new("Solution not found", id: id) unless entry

    new(entry)
  end

  def self.unique_category_ids
    ContentfulClient.entries(
      content_type: "solution",
      select: "fields.categories"
    ).flat_map { |solution| solution.fields[:categories]&.map(&:id) }.compact.uniq
  end

  def ==(other)
    super ||
      other.instance_of?(self.class) && other.id == id
  end

  def as_json(_options = {})
    {
      provider: {
        initials: provider_initials,
        title: provider_name,
      },
      cat: {
        title: categories.first&.title,
        ref: categories.first&.slug,
      },
      links: Array(related_content).map do |content|
        {
          text: content.link_text,
          url: content.url,
        }
      end,
      ref: slug,
      title: title,
      url: url,
      descr: description,
      expiry: expiry,
      body: summary,
      primary_category: {
        title: primary_category&.title,
        ref: primary_category&.slug,
      },

    }
  end
end
