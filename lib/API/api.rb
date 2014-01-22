module Instamojo
  class API
    attr_reader :app_id

    def initialize(app_id = nil, options = {})
      options = app_id if app_id.is_a? Hash

      @app_id = app_id

      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end

      yield self if block_given?
    end

    def client
      Instamojo::Client.new(self)
    end

    def to_s
      sprintf("Instamojo API(key: %s)", @app_id)
    end
  end
end