#Instamojo-rb#
This is the **Ruby** library of [Instamojo API](http://instamojo.com/developers).   
This will assist you to programmatically create, edit and delete offers on Instamojo.

##Installation##
`gem install Instamojo-rb`    

For your Rails/bundler projects:    
`gem 'Instamojo-rb'`

##Usage##

###Set API keys###
```ruby
require 'Instamojo-rb'
api = Instamojo::API.new do |app|
  app.app_id = "app_id-you-received-from-api@instamojo.com"
end
#or
api = Instamojo::API.new("app_id-you-received-from-api@instamojo.com")
```

###Generate client:###
`client = api.client`

###Authentication###
```ruby
client.authenticate('instamojo_username', 'instamojo_password')
#or
client.authenticate do |user|
  user.username = "instamojo_username"
  user.password = "instamojo_password"
end
#=> Instamojo Client(URL: https://www.instamojo.com/api/1, Status: Authenticated)
```

###Offers###
####List all offers####
`client.get_offers`

####List details of an offer####
**Syntax:** `client.get_offer(offer_slug)`

```ruby
client.get_offer('demo-product')
#=> {"offer"=> {"shorturl"=>nil, "start_date"=>nil, "note"=>"", "description"=>"This is a demo product. Just *claim* it. ", "venue"=>nil, "title"=>"Demo product", "url"=>"https://www.instamojo.com/ankurgel/demo-product/", "slug"=>"demo-product", "base_price"=>"0.00", "quantity"=>nil, "end_date"=>nil, "currency"=>"INR", "cover_image"=>nil, "timezone"=>nil, "redirect_url"=>""},
# "success"=>true}
```

####Create an offer####
```ruby
client.create_offer do |offer|
  offer.title = "Command line offer"
  offer.description = "This offer is being created via Instamojo-rb"
  offer.currency = "INR"
  offer.base_price = 0
  offer.quantity = 0
end

#OR
client.create_offer({
  "title" => "Command line offer",
  "description" => "This offer is being created via Instamojo-rb",
  "currency" => "INR",
  "base_price" => 0,
  "quantity" => 0
})
```

####Archive an offer####
`client.delete_offer('demo-product')`

###Logout###
`client.logout`


##Contributing##

* [Fork](https://github.com/AnkurGel/Instamojo-rb/fork) the project
* `bundle install` to satisfy gem dependencies.
* `rake install` to install the gem. 
* Swim around in `lib/`. 

##Copyright##

Copyright (c) 2014 Ankur Goel.

