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

`Link` object contains all the necessary information required to interpret, modify and archive an Instamojo Link. All link operations on client returns one or collectionn of `links`. Original response from Instamojo API for a link is encapsulated in `link.original`, which is immutable.
_Helper methods_ for `Link`:
* `link.to_h` - Returns equivalent Ruby hash for a link
* `link.to_json` - Returns equivalent JSON for a link
* `link.original` - Returns original link data fetched from API.
* `link.save` - Edits updates carried out on Link object at Instamojo.
* `link.archive` - Archives link at Instamojo

 More about it's usage is below.


### Get Links
```ruby
client.links_list
#=> Array of Instamojo::Link objects
```

### Create a new link
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

### Detail of a link
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

### Misc
* `client.authorized` - View last status of api client request.
* `client.response` - View last procured response by client.
* `client.response.code` - View `response_code` of last request sent by client.

## Contributing

* [Fork](https://github.com/AnkurGel/Instamojo-rb/fork) the project
* `bundle install` to satisfy gem dependencies.
* `rake install` to install the gem.
* Swim around in `lib/`.

## Copyright

Copyright (c) 2014 Ankur Goel.

