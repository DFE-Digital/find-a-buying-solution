class ContentfulClient
  include Singleton

  def self.configure(**kwargs)
    instance.configure(**kwargs)
  end

  def self.entries(*args, **kwargs)
    return [] if instance.missing_credentials?

    instance.client.entries(*args, **kwargs)
  rescue Contentful::BadRequest => e
    Rails.logger.error "Contentful query failed: #{e.message}"
    []
  end

  def configure(space:, access_token:, environment:)
    @space = space
    @access_token = access_token
    @environment = environment
    @client = nil
  end

  def missing_credentials?
    @space.blank? || @access_token.blank?
  end

  def client
    return nil if missing_credentials?

    @client ||= Contentful::Client.new(
      space: @space,
      access_token: @access_token,
      environment: @environment
    )
  end
end
