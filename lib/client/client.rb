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
      @conn = Faraday.new(Instamojo::URL, &connection_options)

      #To abstract in /errors.rb
      raise "Supply API with app_id before generating client" unless api.app_id

      @app_id = api.app_id
      add_header("X-App-Id", @app_id)
      @authentication_flag = "Not authenticated"
    end

    def get_connection_object
      @conn #Faraday::Connection object
    end

    def get(request = "/", params = {})
      @request = request
      sanitize_request
      @response = @conn.get(Instamojo::PREFIX + @request, params)
      return sanitize_response
    end

    def post(request, params = {})
      @request = request
      sanitize_request
      @response = @conn.post(Instamojo::PREFIX + @request, params)
      sanitize_response
    end


    #POST /auth/
    #Authenticate, generate token and add header
    def authenticate(username = nil, password = nil, options = {}, &block)
      if username.is_a?(Hash) or password.is_a?(Hash)
        options = username.is_a?(Hash) ? username : password
      end
      options["username"] = username if username and !username.is_a?Hash
      options["password"] = password if password and !password.is_a?Hash


      if block_given?
        block_params = OpenStruct.new
        block.call(block_params)
        options = options.merge(block_params.marshal_dump)
      end
      #to tackle collective hash like:
      #{"username" => "foo", :username => "foo"}
      #added non-recursive basic code in lib/utility.rb
      options.symbolize_keys!

      #Raise error if doesn't find username and password key in options
      @response = post('auth', options)
      if @response.has_key?("success") and @response['success']
        add_header("X-Auth-Token", @response['token'])
      end
      @response
    end


    #GET /offer - List all offers
    def get_offers
      unless get_connection_object.headers.has_key?("X-Auth-Token")
        raise "Please authenticate() to see your offers"
      end
      get('offer')
    end

    #GET /offer/:slug
    def get_offer(slug)
      get("offer/#{slug}")
    end


    #POST /offer/ - Create an offer
    def create_offer(options = {}, &block)
      if block_given?
        block_params = OpenStruct.new
        block.call(block_params)
        options = options.merge(block_params.marshal_dump)
      end
      options.symbolize_keys!
      @response = post('offer', options)
    end


    #DELETE /offer/:slug - Archives an offer
    def delete_offer(slug)

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

    def sanitize_response
      if @response.status == 200
        @authentication_flag = "Authenticated"
        JSON.parse(@response.body)
      else
        begin
          ({:client_error => "Something went wrong",
            :response_code => @response.status
          }).merge(JSON.parse(@response.body))
        rescue JSON::ParserError
          {:response_code => @response.status}
        end
      end
    end

    def add_header(key, value)
      previous_headers = get_connection_object.headers
      get_connection_object.headers = previous_headers.merge({key => value})
    end
  end
end