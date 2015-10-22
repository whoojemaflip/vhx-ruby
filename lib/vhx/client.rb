module Vhx
  class Client
    attr_reader :client_id, :client_secret, :api_base_url, :oauth_token, :api_key, :connection

    def initialize(options = {})
      options            = Hash[options.map{ |k, v| [k.to_sym, v] }]
      @api_base_url      = 'https://api.vhx.tv' || options[:api_base]
      @client_id         = options[:client_id]
      @client_secret     = options[:client_secret]
      @oauth_token       = options[:api_key] ? nil : OAuthToken.new(options, refreshed = false)
      @api_key           = options[:api_key]
      @skip_auto_refresh = options[:skip_auto_refresh]
      @headers           = {}

      configure_connection
    end

    def configure_connection
      @connection = Faraday::Connection.new(url: api_base_url, headers: configured_headers) do |faraday|
        faraday.request  :url_encoded
        faraday.request  :json
        faraday.response :logger
        faraday.use Vhx::Middleware::OAuth2, :vhx_client => self unless @skip_auto_refresh

        faraday.adapter Faraday.default_adapter

        faraday.use Vhx::Middleware::ErrorResponse
        faraday.response :json
      end
      @connection
    end

    def configured_headers
      if access_token
        @headers[:Authorization] = "Bearer #{access_token}"
      elsif api_key
        @headers[:Authorization] = Faraday::Request::BasicAuthentication.header(api_key, '')
      end

      @headers
    end

    def access_token
      unless oauth_token
        return nil
      end

      oauth_token.token
    end

    def expired?
      unless oauth_token
        return false
      end

      oauth_token.expires && oauth_token.expires_at < Time.now.to_i
    end

    def credentials
      unless oauth_token
        return nil
      end

      oauth_token.to_h
    end

    def refresh_access_token!
      conn = @connection.dup
      conn.headers.delete(:Authorization)
      response = conn.post do |req|
        req.url '/oauth/token'
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = {
          grant_type:    'refresh_token',
          refresh_token: oauth_token.refresh_token,
          client_id:     client_id,
          client_secret: client_secret
        }
      end
      @oauth_token = OAuthToken.new(response.body, refreshed = true)

      configure_connection
    end
  end
end
