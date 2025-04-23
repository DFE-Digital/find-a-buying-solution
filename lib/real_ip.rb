class RealIp
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["HTTP_X_FORWARDED_FOR"].present?
      env["HTTP_X_REAL_IP"] = env["HTTP_X_FORWARDED_FOR"].split(",")&.first
    end
    @app.call(env)
  end
end
