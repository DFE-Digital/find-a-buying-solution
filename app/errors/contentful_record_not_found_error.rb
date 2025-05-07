class ContentfulRecordNotFoundError < StandardError
  attr_reader :slug

  def initialize(message = nil, slug: nil)
    super(message)
    @slug = slug
  end
end
