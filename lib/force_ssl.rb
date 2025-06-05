class ForceSsl
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if enforce_ssl?(request)
      redirect_to_ssl(request)
    else
      @app.call(env)
    end
  end

private

  def enforce_ssl?(request)
    Rails.env.production? && request.env["HTTP_X_FORWARDED_PROTO"] != "https"
  end

  # Redirect to HTTPS
  def redirect_to_ssl(request)
    [301, { "Location" => request.url.sub(/^http:/, "https:") }, []]
  end
end
