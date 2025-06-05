class ForceSsl
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if insecure_request?(request)
      redirect_to_ssl(request)
    else
      @app.call(env)
    end
  end

private

  def insecure_request?(request)
    request.env["HTTP_X_FORWARDED_PROTO"] == "http"
  end

  def redirect_to_ssl(request)
    secure_url = request.url.sub(/^http:/, "https:")
    [301, { "Location" => secure_url, "Content-Type" => "text/plain" }, []]
  end
end
