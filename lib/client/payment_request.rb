module Instamojo

=begin Example
{
        "id" => "92e58bd771414d05a5e443b0a85f8b43",
        "phone" => "+919999999999",
        "email" => "foo@example.com",
        "buyer_name" => "John Doe",
        "amount" => "2500",
        "purpose" => "FIFA 16",
        "status" => "Pending",
        "send_sms" => true,
        "send_email" => true,
        "sms_status" => "Pending",
        "email_status" => "Pending",
        "shorturl" => nil,
        "longurl" => "https://www.instamojo.com/@ashwini/92e58bd771414d05a5e443b0a85f8b43",
        "redirect_url" => "http://www.example.com/redirect/",
        "webhook" => "http://www.example.com/webhook/",
        "created_at" => "2015-10-07T21:36:34.665Z",
        "modified_at" => "2015-10-07T21:36:34.665Z",
        "allow_repeated_payments" => false
}
=end

  class PaymentRequest
    attr_accessor :id, :phone, :email, :buyer_name, :amount, :purpose, :status, :send_sms, :send_email, :sms_status
    attr_accessor  :email_status, :shorturl, :longurl, :redirect_url, :webhook, :created_at, :modified_at, :allow_repeated_payments

    attr_reader :original
    include CommonObject

    def initialize(payment_request, client)
      @original = payment_request
      payment_request.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
      @client = client # Reference to client
    end

    def to_s
      sprintf("Instamojo PaymentRequest(id: %s, purpose: %s, amount: %s, status: %s, shorturl: %s, longurl: %s)",
              id, purpose, amount, status, shorturl, longurl)
    end
  end
end