module Instamojo
  module CommonObject
    def to_json
      construct_hash.to_json
    end

    def to_h
      construct_hash
    end

    def construct_hash
      vars = instance_variables.reject { |x| [:@client, :@original].include? x }
      Hash[vars.map { |key| [key.to_s[1..key.length], instance_variable_get(key)] }]
    end
  end
end