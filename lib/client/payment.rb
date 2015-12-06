module Instamojo

=begin Example
{
              "payment_id" => "MOJO3815000F72853519",
                "quantity" => 1,
                  "status" => "Credit",
               "link_slug" => "demo-product",
              "link_title" => "Demo product",
              "buyer_name" => "",
             "buyer_phone" => "",
             "buyer_email" => "nalinc007@gmail.com",
                "currency" => "Free",
              "unit_price" => "0.00",
                  "amount" => "0.00",
                    "fees" => "0",
        "shipping_address" => nil,
           "shipping_city" => nil,
          "shipping_state" => nil,
            "shipping_zip" => nil,
        "shipping_country" => nil,
           "discount_code" => nil,
     "discount_amount_off" => nil,
                "variants" => [],
           "custom_fields" => {},
            "affiliate_id" => nil,
    "affiliate_commission" => nil,
              "created_at" => "2013-08-15T13:16:24.629Z"
}
=end

  class Payment
    attr_accessor :payment_id, :quantity, :status, :link_slug, :link_title, :buyer_name, :buyer_phone, :buyer_email
    attr_accessor  :currency, :unit_price, :amount, :fees, :shipping_address, :shipping_city, :shipping_state, :shipping_zip
    attr_accessor  :shipping_country, :discount_code, :discount_amount_off, :variants, :custom_fields, :affiliate_id, :affiliate_commission, :created_at

    attr_reader :original
    include CommonObject

    def initialize(payment, client)
      @original = payment
      payment.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
      @client = client # Reference to client
    end
  end
end