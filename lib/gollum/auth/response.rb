require 'mustache'

module Gollum::Auth

  module Response

    class << self

      def basic(code, headers, content)
        [code, headers, content]
      end

      def success
        basic(200, {}, ["Success"])
      end

      def error(code, message)
        basic(code, {}, [message])
      end

      def server_error
        error(500, "Internal Server Error")
      end

      def page(content)
        basic(
          200,
          {
            'Content-Type' => 'text/html'
          },
          [ content ]
        )
      end

      def not_authorized
        basic(
          401,
          {
            'Content-Type'     => 'text/plain',
            'WWW-Authenticate' => 'Basic realm="Gollum Wiki"'
          },
          [ 'Not authorized' ]
        )
      end

      def login(config, request, mustache = nil)
        if mustache.nil?
          # Get login.html
          mustache = read_gem_file "views/login.mustache"
        end

        page = request.params['page']
        page Mustache.render(mustache, auth: auth_js(config, page))
      end

      private

      def remove_query_from_path(path)
        match = /(.+?)(?:\?|$).*/.match(path)
        match.captures[0]
      end

      def gem_path
        File.join(File.dirname(__FILE__), "../../../")
      end

      def read_gem_file(path)
        file = File.open(File.join(gem_path, path))
        file.read
      end

      def auth_js(config, page)
        js = read_gem_file "views/auth.mustache"
        Mustache.render(
          js,
          config: config.to_json,
          login_path: ::Gollum::Auth::LOGIN_PATH,
          page: page
        )
      end

    end

  end

end
