module Instamojo
  class Response
    attr_reader :body, :code

    def initialize(hash)
      @code = hash.status
      if hash.body
        begin
          @body = JSON.parse(hash.body)
        rescue JSON::ParserError
          @body = {:client_error => "Something went wrong", :original => hash.body.to_s}
        end
        @body.symbolize_keys!
        @status = @body[:success]
      end
    end

    def response_success?
      [200, 201, 202, 203, 204].include? @code
    end

    def success?
      (@status && (@status.eql?(true) || @status.downcase == 'success')) || response_success?
    end
  end
end