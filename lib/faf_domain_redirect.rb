# Find a Framework domain redirect
class FafDomainRedirect
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    if request.host == ENV.fetch("FAF_DOMAIN", nil)
      [301, { "Location" => "/" }, []]
    else
      @app.call(env)
    end
  end
end
