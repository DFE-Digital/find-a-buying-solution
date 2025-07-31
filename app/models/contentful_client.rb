require "singleton"

class ContentfulClient
  include Singleton

  def self.configure(**kwargs)
    instance.configure(**defaults.merge(kwargs))
  end

  def self.entries(*args, **kwargs)
    instance.client.entries(*args, **kwargs)
  end

  def configure(space:, access_token:, environment:)
    @space = space
    @access_token = access_token
    @environment = environment
    @client = nil
  end

  def client
    @client ||= Contentful::Client.new(
      space: @space,
      access_token: @access_token,
      environment: @environment
    )
  end

  def self.defaults
    {
      space: ENV.fetch("CONTENTFUL_SPACE_ID", "FAKE_SPACE_ID"),
      access_token: ENV.fetch("CONTENTFUL_ACCESS_TOKEN", "FAKE_API_KEY"),
      environment: ENV.fetch("CONTENTFUL_ENVIRONMENT", "master"),
    }
  end

  private_class_method :defaults
end
