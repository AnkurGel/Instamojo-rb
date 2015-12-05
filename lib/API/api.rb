module Instamojo

  class << API
    private
    def whitelist_parameters
      API::WHITELISTED_API_PARAMS.each { |x| attr_reader x }
    end
  end

  class API
    WHITELISTED_API_PARAMS = [:api_key, :auth_token]
    whitelist_parameters
    attr_reader :client

    def initialize(api_key = nil, auth_token = nil, options = {}, &block)
      options = find_params(api_key, auth_token, options, block)

      options.select { |k, _| WHITELISTED_API_PARAMS.include? k.to_sym }.each do |key, value|
        instance_variable_set("@#{key}", value)
      end

    end

    def client
      @client ||= Instamojo::Client.new(self)
    end

    def to_s
      sprintf("Instamojo API(key: %s)", @api_key)
    end

    private

    def find_params(api_key, auth_token, options, block)
      if api_key.is_a? Hash
        api_key
      elsif api_key
        { api_key: api_key, auth_token: auth_token }
      elsif block
        struct = OpenStruct.new
        block.call(struct) && struct.marshal_dump
      else options
      end
    end
  end
end