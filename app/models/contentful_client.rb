require "singleton"

class ContentfulClient
  include Singleton

  def self.configure(**kwargs)
    instance.configure(**kwargs)
  end

  def self.entries(*args, **kwargs)
    instance.client.entries(*args, **kwargs)
  end

  def configure(space:, access_token:)
    @space = space
    @access_token = access_token
    @client = nil
  end

  def client
    @client ||= Contentful::Client.new(
      space: @space,
      access_token: @access_token,
      dynamic_entries: :auto,
    )
  end
end
