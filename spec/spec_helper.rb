ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require_relative '../app'

include Rack::Test::Methods

def app
  CodecadetApp
end

def random_str(n)
  (0..n).map { ('a'..'z').to_a[rand(26)] }.join
end
