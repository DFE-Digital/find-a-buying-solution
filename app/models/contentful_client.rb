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
    return if @space && @access_token

    @space = space
    @access_token = access_token
  end

  def client
    unless @space && @access_token
      configure(
        space: ENV.fetch("CONTENTFUL_SPACE_ID", "FAKE_SPACE_ID"),
        access_token: ENV.fetch("CONTENTFUL_ACCESS_TOKEN", "FAKE_API_KEY"),
      )
    end

    @client ||= Contentful::Client.new(
      space: @space,
      access_token: @access_token,
      dynamic_entries: :auto,
    )
  end
end
