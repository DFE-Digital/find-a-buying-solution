class ForceSSL
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
    [301, { "Location" => request.url.sub(/^http:/, "https:") }, []]
  end
end
