# Instamojo-rb
This is the **Ruby** library of [Instamojo REST API](https://www.instamojo.com/developers/rest/).
This will assist you to programmatically create, edit and delete links on Instamojo. Also supports [RAP](https://www.instamojo.com/developers/request-a-payment-api/) api for payments request, listing and status.

## Installation
`gem install Instamojo-rb`
For your Rails/bundler projects:
`gem 'Instamojo-rb'`

## Usage
### Set API keys
```ruby
require 'Instamojo-rb'
api = Instamojo::API.new do |app|
  app.api_key = "api_key-you-received-from-api@instamojo.com"
  app.auth_token = "auth_token-you-received-from-api@instamojo.com"
end
#or
api = Instamojo::API.new("api_key-you-received-from-api@instamojo.com", "auth_token-you-received-from-api@instamojo.com")
```
### Generate client
`client = api.client`

---
### Links

`Link` object contains all the necessary information required to interpret, modify and archive an Instamojo Link. All link operations on client returns one or collectionn of `links`. Original response from Instamojo API for a link is encapsulated in `link.original`, which is immutable. Call `#to_h` on `link` to get it's all attributes.
_Helper methods_ for `Link`:
* `link.to_h` - Returns equivalent Ruby hash for a link.
* `link.to_json` - Returns equivalent JSON for a link
* `link.original` - Returns original link data fetched from API.
* `link.save` - Edits updates carried out on Link object at Instamojo.
* `link.archive` - Archives link at Instamojo
* `link.reload` or `link.refresh` - Looks for changes on Instamojo server for the link. Immutable
* `link.reload!` or `link.refresh!` - Same as `link.reload`, but mutable.

 More about it's usage is below.


#### Get Links
```ruby
client.links_list
#=> Array of Instamojo::Link objects
```

#### Create a new link
##### Required:
* `title` - Title of the Link, be concise.
* `description` - Describe what your customers will get, you can add terms and conditions and any other relevant information here. Markdown is supported, popular media URLs like Youtube, Flickr are auto-embedded.
* `base_price` - Price of the Link. This may be 0, if you want to offer it for free.

##### File and Cover image:
* `file_upload` - Full path to the file you want to sell. This file will be available only after successful payment.
* `cover_image` - Full path to the IMAGE you want to upload as a cover image.

##### Quantity:
* `quantity` - Set to 0 for unlimited sales. If you set it to say 10, a total of 10 sales will be allowed after which the Link will be made unavailable.

##### Post Purchase Note
* `note` - A post-purchase note, will only displayed after successful payment. Will also be included in the ticket/ receipt that is sent as attachment to the email sent to buyer. This will not be shown if the payment fails.

##### Event
* `start_date` - Date-time when the event is beginning. Format: `YYYY-MM-DD HH:mm`
* `end_date` - Date-time when the event is ending. Format: `YYYY-MM-DD HH:mm`
* `venue` - Address of the place where the event will be held.
* `timezone` - Timezone of the venue. Example: Asia/Kolkata

##### Redirects and Webhooks
* `redirect_url` - This can be a Thank-You page on your website. Buyers will be redirected to this page after successful payment.
* `webhook_url` - Set this to a URL that can accept POST requests made by Instamojo server after successful payment.
* `enable_pwyw` - set this to True, if you want to enable Pay What You Want. Default is False.
* `enable_sign` - set this to True, if you want to enable Link Signing. Default is False. For more information regarding this, and to avail this feature write to support at instamojo.com.

##### Code:
```ruby
new_link = client.create_link do |link|
  link.title = 'API link v1.1'
  link.description = 'Dummy offer via API'
  link.currency = 'INR'
  link.base_price = 0
  link.quantity = 10
  link.redirect_url = 'http://ankurgoel.com'
  link.file_upload = '~/Pictures/RISE.jpg'
  link.cover_image = '~/Pictures/saturday.jpg'
end
#=> Instamojo Link(slug: api-link-v11, title: API link v1.1, shorturl: )
new_link.reload!
#=> Instamojo Link(slug: api-link-v11, title: API link v1.1, shorturl: http://imojo.in/1dxv1h)
```
or
```ruby
new_link_params = {base_price: 199, title: 'API link 3', description: 'My dummy offer via API', currency: 'INR', quantity: 20}
new_link = client.create_link(new_link_params)
```

#### Detail of a link
```ruby
link = client.link_detail('link_slug_goes_here')
#=> Instamojo Link(slug: link_slug_goes_here, title: Foo Bar, shorturl: http://imojo.in/ankurfoobar)
link.to_h
#=> {"title"=>"Foo Bar", "description"=>"", "slug"=>"foo-product", "shorturl"=>"http://imojo.in/ankurfoobar", "url"=>"https://www.instamojo.com/ankurgel/foo-product/", "cover_image"=> "https://www.filepicker.io/api/file/BHeefKAARCKGC5l1J29e/convert?w=500&h=500&fit=clip&quality=70", "currency"=>"INR", "base_price"=>"0.00", "quantity"=>nil, "quantity_sold"=>2, "requires_shipping"=>false, "ships_within_days"=>nil, "start_date"=>nil, "end_date"=>nil, "venue"=>"", "timezone"=>"", "note"=>"", "redirect_url"=>"", "webhook_url"=>"", "status"=>"Live", "enable_pwyw"=>false, "enable_sign"=>false, "socialpay_platforms"=>""}
```

#### Edit a link
```ruby
link = client.links_list.first
link.save do |l|
  l.title = "Foo"
  l.description = "This new information should go in link"
end
#=> Returns updated Link object from Instamojo
```
or
```ruby
link = client.link_detail('foo-product')
link.title = 'Foo'; link.description = 'This new information should go in link'
link.save
# returns updated Link object from Instamojo
```
or handle it directly without Link object
```ruby
client.edit_link({slug: 'foo-product', title: 'Foo', description: 'This new infromation should go in link'})
```

---
### Payments
`Payment` object contains the necessary information such as `payment_id`, `quantity`, `status`, `buyer_email` etc. Call `#to_h` on `payment` to get it's all attributes. `Payment` object has following helpers:
- `payment.to_h` - Returns equivalent Ruby hash for a payment
- `payment.to_json` - Returns equivalent JSON for a payment
- `payment.original` - Returns original payment data fetched from API.
- Like `Link`, it also exposes `reload` and `reload!`

Details are documented [here](https://www.instamojo.com/developers/rest/#toc-payments)

#### Get Payments
```ruby
client.payments_list
#=> Returns array of Payment objects
```
#### Detail or status of a payment
```ruby
payment = client.payment_detail('MOJxxx06000F97367750')
#=> Instamojo Payment(payment_id: MOJxxx06000F97367750, quantity: 1, amount: 0.00, status: Credit, link_slug: api-link-7-node, buyer_name: Ankur Goel)
payment.to_h
#=> Hash of all payment object attributes
```
#### Request a payment
This is a part of [RAP API](https://www.instamojo.com/developers/request-a-payment-api/). You can request a payment from anyone via this who will then be notified to make a payment with specified payment. The payment then can be carried out via [Instapay](https://www.instamojo.com/pay/). Jump over to the documentation to see accepted parameters.
##### Code:
```ruby
payment_request = client.payment_request({amount:100, purpose: 'api', send_email: true, email: 'ankurgel+2@gmail.com', redirect_url: 'http://ankurgoel.com'})
#=> Instamojo PaymentRequest(id: 8726f8c5001e426f8b24e908b2761686, purpose: api, amount: 100.00, status: Sent, shorturl: , longurl: https://www.instamojo.com/@ashwini/8726f8c5001e426f8b24e908b2761686)
```
#### Get Payment Requests
```ruby
payment_requests = client.payment_requests_list
#=> Returns array of PaymentRequest objects
```
#### Status of payment request
You can get the status of a payment_request from the id you obtained after making payment request.
```ruby
payment_request.reload!
#or
payment_request = client.payment_request_status('8726f8c5001e426f8b24e908b2761686')
#=> Instamojo PaymentRequest(id: 8726f8c5001e426f8b24e908b2761686, purpose: api, amount: 100.00, status: Sent, shorturl: http://imjo.in/Nasdf , longurl: https://www.instamojo.com/@ashwini/8726f8c5001e426f8b24e908b2761686)
```
---
### Refunds
`Refund` object contains the necessary information such as `payment_id`, `refund_amount`, `status` and `body` etc. Call `#to_h` on `refund` to get it's all attributes. `Refund` object has the same helpers as `Payment` above, including `reload` and `reload!`.

#### Get Refunds
```ruby
refunds = client.refunds_list
#=> Returns array of Refund objects
```

#### Create a new refund
##### Required:
* `payment_id` - Payment ID of the payment against which you're initiating the refund.
* `type` - A three letter short-code identifying the [reason for this case](https://www.instamojo.com/developers/rest/#toc-refunds).
* `body` - Additonal text explaining the refund.

```ruby
client.create_refund({payment_id: 'MOJO5c04000J30502939', type: 'QFL', body: 'Customer is not satisfied'})
#=> Returns Refund object or non-200 response object
```
or
```ruby
client.create_refund do |refund|
  refund.payment_id = 'MOJO5c04000J30502939'
  refund.type       = 'QFL'
  refund.body       = 'Customer is not satisifed'
end
```
or refund a `payment` directly:
```ruby
payment = client.payment_detail('MOJO5c05000F97367750')
payment.process_refund(type: 'QFL', body: 'User wanted different version') #or
payment.process_refund do |refund|
  refund.type = 'QFL'
  refund.body = 'User wanted different version'
end
```

#### Details of a refund
```ruby
refund = client.refund_detail 'C5c0751269'
#=> Instamojo Refund(id: C5c0751269, status: 'Refunded' payment_id: MOJO5c04000J30502939, refund_amount: 100)
refund.to_h
#=> Hash of all refund attributes
refund.reload!
#=> Updates the refund from server
#=> Instamojo Refund(id: C5c0751269, status: 'Closed' payment_id: MOJO5c04000J30502939, refund_amount: 100)
```
or
```ruby
refunds = client.refunds_list
refund = refunds.last
refund.reload #=> refetches the refund from server
#=> Instamojo Refund(id: C5c0751269, status: 'Refunded' payment_id: MOJO5c04000J30502939, refund_amount: 100)
```

---
### Authentication
```ruby
client.authenticate('instamojo_username', 'instamojo_password')
#or
client.authenticate do |user|
  user.username = "instamojo_username"
  user.password = "instamojo_password"
end
#=> Instamojo Client(URL: https://www.instamojo.com/api/1, Status: Authenticated)
```
#### Logout
```ruby
client.logout
```
---
### Misc
* `client.authorized` - View last status of api client request.
* `client.response` - View last procured response by client.
* `client.response.code` - View `response_code` of last request sent by client.

#### Logging
If you are interested in seeing api requests being made to Instamojo server. Flip this flag: `Instamojo::DEBUG = true` and genereate the api client again.


## Contributing

* [Fork](https://github.com/AnkurGel/Instamojo-rb/fork) the project
* `bundle install` to satisfy gem dependencies.
* `rake install` to install the gem.
* Swim around in `lib/`.

## Contributors
1. Ashwini Chaudhary - [@ashwch](https://github.com/ashwch)
   * [PR #3](https://github.com/AnkurGel/Instamojo-rb/pull/3) - Couple of minor fixes.
   * [PR #4](https://github.com/AnkurGel/Instamojo-rb/pull/4) - Class wrapper over Payment Request. Code fixes.

## Copyright

Copyright (c) 2014 Ankur Goel.

