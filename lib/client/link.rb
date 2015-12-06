module Instamojo

=begin Example
{
                  "title" => "Foo product",
            "description" => "",
                   "slug" => "foo-product",
               "shorturl" => "http://imojo.in/ankurfoobar",
                    "url" => "https://www.instamojo.com/ankurgel/foo-product/",
            "cover_image" => "https://www.filepicker.io/api/file/BHeefKAARCKGC5l1J29e/convert?w=500&h=500&fit=clip&quality=70",
               "currency" => "INR",
             "base_price" => "0.00",
               "quantity" => nil,
          "quantity_sold" => 2,
      "requires_shipping" => false,
      "ships_within_days" => nil,
             "start_date" => nil,
               "end_date" => nil,
                  "venue" => nil,
               "timezone" => nil,
                   "note" => nil,
           "redirect_url" => nil,
            "webhook_url" => nil,
                 "status" => "Live",
            "enable_pwyw" => false,
            "enable_sign" => false,
    "socialpay_platforms" => ""
}
=end

  class Link
    attr_accessor :title, :description, :slug, :shorturl, :url, :cover_image, :currency, :base_price, :quantity
    attr_accessor :quantity_sold, :requires_shipping, :ships_within_days, :start_date, :end_date, :venue, :timezone
    attr_accessor :note, :redirect_url, :webhook_url, :status, :enable_pwyw, :enable_sign, :socialpay_platforms

    attr_reader :original

    def initialize(link, client)
      @original = link
      link.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
      @client = client # Reference to client
    end

    # Carry out update request on a Link
    def save(&block)
      @client.edit_link(self, {}, &block)
    end

    # Carry out DELETE request on a link
    def archive
      @client.archive_link(self.slug)
    end

    def to_json
      construct_hash.to_json
    end

    def to_h
      construct_hash
    end

    private
    def construct_hash
      vars = instance_variables.reject { |x| [:@client, :@original].include? x }
      Hash[vars.map { |key| [key.to_s[1..key.length], instance_variable_get(key)] }]
    end
  end
end