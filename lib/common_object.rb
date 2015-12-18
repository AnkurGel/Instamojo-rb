module Instamojo
  module CommonObject

    # Common intializer
    def assign_values(object)
      @original = object
      object.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
      self
    end

    # Return link/payment/payment_request/refund as json
    def to_json
      construct_hash.to_json
    end

    # Return link/payment/payment_request/refund as hash
    def to_h
      construct_hash
    end

    # Reload the link/payment/payment_request/refund from the server
    def reload
      @client.send(*self.detail_helper)
    end

    # Same as relaod but mutable
    def reload!
      obj = reload
      obj.instance_of?(self.class) ? assign_values(obj.to_h) : obj
    end

    # Construct hash from mutated parameters
    def construct_hash
      vars = instance_variables.reject { |x| [:@client, :@original].include? x }
      Hash[vars.map { |key| [key.to_s[1..key.length], instance_variable_get(key)] }]
    end

    alias_method :refresh, :reload
    alias_method :refresh!, :reload!
    def self.included(klass)
      klass.extend(KlassMethods)
    end

    module KlassMethods
      def detail_method(detail, key)
        define_method "detail_helper" do
          [detail, self.send("#{key}")]
        end
      end
    end
  end
end
