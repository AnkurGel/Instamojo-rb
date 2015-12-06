# Instamojo-rb
This is the **Ruby** library of [Instamojo API](http://instamojo.com/developers).   
This will assist you to programmatically create, edit and delete links on Instamojo. Also supports payments request, listing and status.

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

### Links

`Link` object contains all the necessary information required to interpret, modify and archive an Instamojo Link. All link operations on client returns one or collectionn of `links`. Original response from Instamojo API for a link is encapsulated in `link.original`, which is immutable. More about it's usage is below.


## Get Links
```ruby
client.links_list
#=> Array of Instamojo::Link objects
```

## Create a new link
```ruby
new_link = client.create_link do |link|
  link.title = 'API link 2'
  link.description = 'Dummy offer via API'
  link.currency = 'INR'
  link.base_price = 0
  link.quantity = 10
  link.redirect_url = 'http://ankurgoel.com'
end
#=> Link object
```
or
```ruby
new_link_params = {title: 'API link 3', description: 'My dummy offer via API', currency: 'INR', quantity: 20}
new_link = client.create_link(new_link_params)
```

## Detail of a link
```ruby
link = client.link_detail('link_slug_goes_here')
#=> Returns Link object

## Edit a link
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

### Logging
If you are interested in seeing api requests being made to Instamojo server. Flip this flag: `Instamojo::DEBUG = true` and genereate the api client again. 

### Logout
`client.logout`


## Contributing

* [Fork](https://github.com/AnkurGel/Instamojo-rb/fork) the project
* `bundle install` to satisfy gem dependencies.
* `rake install` to install the gem. 
* Swim around in `lib/`. 

## Copyright

Copyright (c) 2014 Ankur Goel.
