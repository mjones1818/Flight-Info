require 'bundler/setup'
Bundler.require(:default)

require 'pry'
require 'net/http'
require 'open-uri'
require 'json'

require_relative '../lib/cli.rb'
require_relative '../lib/api.rb'
require_relative '../lib/airlines.rb'
require_relative '../lib/flights.rb'