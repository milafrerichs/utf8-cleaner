module UTF8Cleaner
  class Middleware

    SANITIZE_ENV_KEYS = [
     "HTTP_REFERER",
     "PATH_INFO",
     "QUERY_STRING",
     "REQUEST_PATH",
     "REQUEST_URI",
     "HTTP_COOKIE"
    ]

    SANITIZE_ENV_KEY_IO = [
      "rack.input"
    ]

    def initialize(app)
     @app = app
    end

    def call(env)
     @app.call(sanitize_env(env))
    end

    private

    def sanitize_env(env)
      SANITIZE_ENV_KEYS.each do |key|
        next unless value = env[key]

        if value.include?('%')
          env[key] = URIString.new(value).cleaned
        end
      end
      SANITIZE_ENV_KEY_IO.each do |key|
        next unless value = env[key]
        value = env[key].string
        if value.include?('%')
          env[key] = StringIO.new(URIString.new(value).cleaned)
        end
      end
      env
    end
  end
end
