require 'faraday'
require 'json'
require 'uri'
require 'ostruct'
require_relative 'API/api'
require_relative 'client/client'
require_relative 'utility'

module Instamojo
  URL = "https://www.instamojo.com"
  PREFIX = "/api/1"
end
