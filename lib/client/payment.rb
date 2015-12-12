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
    detail_method :payment_detail, :payment_id

    def initialize(payment, client)
      assign_values(payment)
      @client = client # Reference to client
    end

    # Process refund for this payment
    # payment.process_refund(type: 'QFL', body: 'Customer is not satisfied')
    def process_refund(hash = {}, &block)
      hash[:payment_id] = self.payment_id
      @client.create_refund(hash, &block)
    end

    def to_s
      sprintf("Instamojo Payment(payment_id: %s, quantity: %s, amount: %s, status: %s, link_slug: %s, buyer_name: %s)",
              payment_id, quantity, amount, status, link_slug, buyer_name)
    end
  end
end
