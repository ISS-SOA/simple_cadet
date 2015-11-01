require_relative 'spec_helper'
require 'json'

describe 'Getting the root of the service' do
  it 'Should return ok' do
    get '/'
    last_response.must_be :ok?
    last_response.body.must_match(/simplecadet/i)
  end
end

describe 'Getting cadet information' do
  it 'should return their badges' do
    VCR.use_cassette('cadet') do
      get '/api/v1/cadet/soumya.ray.json'
    end
    last_response.must_be :ok?
  end

  it 'should return 404 for unknown user' do
    VCR.use_cassette('cadet_empty') do
      get "/api/v1/cadet/#{random_str(20)}.json"
    end
    last_response.must_be :not_found?
  end
end
