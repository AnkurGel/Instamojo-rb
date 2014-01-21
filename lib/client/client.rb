module Instamojo
  class Client
    attr_reader :connection_options, :app_id, :token
    attr_reader :request, :response
    attr_reader :authentication_flag

    def connection_options
      @connection_options = lambda do |connection|
        connection.request :url_encoded
        connection.response :logger
        connection.adapter Faraday.default_adapter
      end
    end

    def initialize(api)
      #@conn = Faraday.new(Instamojo::URL, &@connection_options)
      @conn = Faraday.new("https://instamojo.com") do |c|
        c.request :url_encoded
        c.response :logger
        c.adapter Faraday.default_adapter
      end
      @conn.headers = @conn.headers.merge({"X-App-Id" => api.app_id})
      @app_id = api.app_id
      #add_header(:accept, 'application/json')
      #add_header("X-App-Id", @app_id)
      @authentication_flag = "Not authenticated"
    end

    def get_connection_object
      @conn #Faraday::Connection object
    end

    def get(request = "/", params = {})
      @request = request
      sanitize_request
      @response = @conn.get(Instamojo::PREFIX + @request, params)
      begin
        JSON.parse(@response.body)
        {:response_code => @response.status}.merge(JSON.parse(@response.body)) if @response.status != 200
      rescue JSON::ParserError
        {:message => "Something went wrong. Expected JSON"}
      end
    end

    def post(request, params)
      @request = request
      sanitize_request
      @response = @conn.post(Instamojo::PREFIX + @request, params)
      JSON.parse(@response.body)
    end


    def authenticate(username, password)

    end

    def to_s
      sprintf("Instamojo Client(URL: %s, Status: %s)",
              Instamojo::URL + Instamojo::PREFIX,
              @authentication_flag
      )
    end


    private
    def sanitize_request
      @request.concat('/') unless request.end_with? "/"
      @request.prepend('/') unless request.start_with? "/"
    end

    def generate_token(username, password)
      #Do POST request on /auth and extract token on successful authorization
      response = @conn.post('/auth', {:username => username,
                                      :password => password
      })

    end

    def add_header(key, value)
      previous_headers = get_connection_object.headers
      get_connection_object.headers = previous_headers.merge({key => value})
    end
  end
end