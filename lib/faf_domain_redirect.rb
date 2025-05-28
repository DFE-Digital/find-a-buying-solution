# Find a Framework domain redirect
class FafDomainRedirect
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    if request.host == ENV.fetch("FAF_DOMAIN", nil)
      uri = URI::HTTPS.build(host: ENV["APP_DOMAIN"], path: "/", query: URI.encode_www_form(source: request.url))
      [301, { "Location" => uri.to_s }, []]
    else
      @app.call(env)
    end
  end
end
