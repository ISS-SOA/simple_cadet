ENV['RACK_ENV'] = 'test'

Dir.glob('./{models,helpers,controllers}/*.rb').each { |file| require file }
require 'minitest/autorun'
require 'rack/test'
require 'vcr'
require 'webmock/minitest'

include Rack::Test::Methods

def app
  ApplicationController
end

def random_str(n)
  srand(n)
  (0..n).map { ('a'..'z').to_a[rand(26)] }.join
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
end
