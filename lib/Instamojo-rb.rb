require 'faraday'
require 'json'
require 'uri'
require_relative 'API/api'
require_relative 'client/client'

module Instamojo
  URL = "https://instamojo.com"
  PREFIX = "/api/1"
end
