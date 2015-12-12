module Instamojo
  class Client
    attr_reader :connection_options, :app_id
    attr_reader :request, :response
    attr_reader :authorized

    URL = Instamojo::HOST + "/api/" + Instamojo::API_VERSION

    def connection_options
      @connection_options = lambda do |connection|
        connection.request :url_encoded
        connection.response :logger if Instamojo::DEBUG # TODO: set DEBUG flag for this
        connection.adapter Faraday.default_adapter
      end
    end

    def initialize(api, endpoint)
      @endpoint = endpoint || URL
      @conn = Faraday.new(@endpoint, &connection_options)

      #TODO: To abstract in /errors.rb
      raise "Supply API with api_key before generating client" unless api.api_key

      @api_key = api.api_key
      @auth_token = api.auth_token
      add_header "X-Api-Key", @api_key
      if @auth_token
        add_header "X-Auth-Token", @auth_token
        get 'debug' # dummy request to verify supplied auth_token
      else
        @authorized = "Not authorized"
      end
    end

    def get_connection_object
      @conn
    end

    def self.define_http_verb(http_verb)
      define_method http_verb do |*args|
        request = args[0] || "/"
        params = args[1] || {}

        @request = request
        sanitize_request
        method = @conn.method(http_verb)
        @response = method.call(@request, params)
        sanitize_response
      end
    end

    define_http_verb :get
    define_http_verb :post
    define_http_verb :patch
    define_http_verb :delete


    # POST /auth/
    # Authenticate, generate token and add header
    def authenticate(username = nil, password = nil, options = {}, &block)
      if username.is_a?(Hash) or password.is_a?(Hash)
        options = username.is_a?(Hash) ? username : password
      end
      options["username"] = username if username and !username.is_a?Hash
      options["password"] = password if password and !password.is_a?Hash

      options = set_options(options, &block)

      #TODO: Raise error if doesn't find username and password key in options
      @response = post('auth', options)
      if @response.has_key?("success") and @response['success']
        add_header("X-Auth-Token", @response['token'])
      end
      @response
    end

    # GET /links
    def links_list
      get('links')
      @response.success? ? @response.body[:links].map { |link| Instamojo::Link.new link, self } : @response
    end

    # GET /links/:slug
    def link_detail(slug)
      get("links/#{slug}")
      @response.success? ? Instamojo::Link.new(@response.body[:link], self) : @response
    end

    # POST /links
    def create_link(options = {}, &block)
      options = set_options(options, &block)
      options[:file_upload_json] = options[:file_upload] && upload_file(options.delete(:file_upload))
      options[:cover_image_json] = options[:cover_image] && upload_file(options.delete(:cover_image))
      post('links', options)
      @response.success? ? Instamojo::Link.new(@response.body[:link], self) : @response
    end

    # PATCH /links/:slug
    def edit_link(link = nil, options = {}, &block)
      if link && link.is_a?(Instamojo::Link)
        yield(link) if block_given?
      else
        options = set_options(options, &block)
        link = Instamojo::Link.new(options, self)
      end
      patch("links/#{link.slug}", link.to_h)
      @response.success? ? Instamojo::Link.new(@response.body[:link], self) : @response
    end

    # DELETE /links/:slug
    def archive_link(slug)
      delete("links/#{slug}")
    end

    # POST 'https://filepicker.io/api/store/S3'
    def upload_file(filepath)
      if filepath && (file=File.open(File.expand_path(filepath), 'rb'))
        if (url=get_file_upload_url).is_a? String
          resource = RestClient::Resource.new(url)
          resource.post fileUpload: file
        end
      end
    end


    # GET /payments
    def payments_list
      get('payments')
      @response.success? ? @response.body[:payments].map { |payment| Instamojo::Payment.new payment, self } : @response
    end

    # GET /payments/:payment_id
    def payment_detail(payment_id)
      get("payments/#{payment_id}")
      @response.success? ? Instamojo::Payment.new(@response.body[:payment], self) : @response
    end

    # POST /payment-requests
    def payment_request(options, &block)
      set_options(options, &block)
      post('payment-requests', options)
      @response.success? ? Instamojo::PaymentRequest.new(@response.body[:payment_request], self) : @response
    end

    # GET /payment-requests
    def payment_requests_list
      get('payment-requests')
      @response.success? ? @response.body[:payment_requests].map { |payment_request| Instamojo::PaymentRequest.new payment_request, self } : @response
    end

    def payment_request_status(payment_request_id)
      get("payment-requests/#{payment_request_id}") if payment_request_id
      @response.success? ? Instamojo::PaymentRequest.new(@response.body[:payment_request], self) : @response
    end

    # GET /refunds
    def refunds_list
      get('refunds')
      @response.success? ? @response.body[:refunds].map { |refund| Instamojo::Refund.new refund, self } : @response
    end

    # GET /refunds/:refund_id
    def refund_detail(refund_id)
      get("refunds/#{refund_id}")
      @response.success? ? Instamojo::Refund.new(@response.body[:refund], self) : @response
    end

    # POST /refunds
    def create_refund(options = {}, &block)
      options = set_options(options, &block)
      post('refunds', options)
      @response.success? ? Instamojo::Refund.new(@response.body[:refund], self) : @response
    end

    # DELETE /auth/:token - Delete auth token
    def logout
      auth_token = get_connection_object.headers['X-Auth-Token']
      raise "Can't find any authorization token to logout." unless auth_token
      @response = delete("/auth/#{auth_token}")
      if @response.has_key?("success") and @response['success']
        get_connection_object.headers.delete("X-Auth-Token")
      end
      @response
    end

    def to_s
      sprintf("Instamojo Client(URL: %s, Authorized: %s)", @endpoint, @authorized)
    end

    private
    def sanitize_request
      @request.concat('/') unless request.end_with? "/"
      @request[0] = '' if request.start_with? "/"
    end

    def sanitize_response
      @response = Instamojo::Response.new(@response)
      @authorized = @response.success?
      @response
    end

    def set_options(options, &block)
      if block_given?
        block_params = OpenStruct.new
        block.call(block_params)
        options = options.merge(block_params.marshal_dump)
      end

      options.symbolize_keys!
    end

    def add_header(key, value)
      previous_headers = get_connection_object.headers
      get_connection_object.headers = previous_headers.merge({key => value})
    end

    # GET /links/get_file_upload_url
    def get_file_upload_url
      get('links/get_file_upload_url')
      @response.success? ? @response.body[:upload_url] : @response
    end
  end
end
