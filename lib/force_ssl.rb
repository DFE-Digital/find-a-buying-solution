class ForceSsl
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    dump = request.env.map { |k, v| "#{k}: #{v}" }.join("\n")

    [200, { "Content-Type" => "text/plain" }, [dump]]
  end
end
