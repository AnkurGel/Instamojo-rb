module Instamojo

  class ::Hash
    def symbolize_keys
      self.inject({}) do |initial, (k, v)|
        initial[k.to_sym] = v
        initial
      end
    end

    def symbolize_keys!
      self.replace(self.symbolize_keys)
    end
  end
end