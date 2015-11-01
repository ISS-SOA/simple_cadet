require_relative 'spec_helper'
require 'json'

describe 'Getting cadet information' do
  it 'should return their badges' do
    VCR.use_cassette('cadet') do
      get '/api/v1/cadets/soumya.ray.json'
    end
    last_response.must_be :ok?
  end

  it 'should return 404 for unknown user' do
    VCR.use_cassette('cadet_empty') do
      get "/api/v1/cadets/#{random_str(20)}.json"
    end
    last_response.must_be :not_found?
  end
end
