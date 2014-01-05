module Instamojo
  class API
    attr_reader :app_id

    def initialize(app_id)
      @app_id = app_id
    end

    def client
      Instamojo::Client.new(self)
    end

    def to_s
      sprintf("Instamojo API(key: %s)", @app_id)
    end
  end
end