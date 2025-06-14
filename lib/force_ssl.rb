class ForceSsl
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if plain_http?(request)
      redirect_to_ssl(request)
    else
      @app.call(env)
    end
  end

private

  def plain_http?(request)
    Rails.env.production? && request.env["SERVER_PORT"] == "80"
  end

  # Redirect to HTTPS
  def redirect_to_ssl(request)
    [301, { "Location" => request.url.sub(/^http:/, "https:") }, []]
  end
end
