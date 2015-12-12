module Instamojo

=begin example
{
    "refund_amount" => "100",
       "payment_id" => "MOJO5c04000J30502939",
             "body" => "Customer isn't satisfied with the quality",
           "status" => "Refunded",
       "created_at" => "2015-12-07T11:01:37.640Z",
               "id" => "C5c0751269",
     "total_amount" => "100.00",
             "type" => "QFL"
}
=end

  class Refund
    attr_accessor :id, :payment_id, :status, :type, :body, :refund_amount, :total_amount, :created_at

    attr_reader :original

    include CommonObject
    detail_method :refund_detail, :payment_id

    def initialize(refund, client)
      assign_values(refund)
      @client = client
    end

    def to_s
      sprintf("Instamojo Refund(id: %s, status: %s, payment_id: %s, refund_amount: %s)",
              id, status, payment_id, refund_amount)
    end

  end
end