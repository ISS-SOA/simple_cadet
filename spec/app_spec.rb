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

describe 'Checking users for badges' do
  it 'should find missing badges' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      usernames: ['soumya.ray', 'chenlizhan'],
      badges: ['Object-Oriented Programming II']
    }

    VCR.use_cassette('check') do
      post '/api/v1/check', body.to_json, header
    end
    last_response.must_be :ok?
  end

  it 'should return 404 for unknown users' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      usernames: [random_str(15), random_str(15)],
      badges: [random_str(30)]
    }

    VCR.use_cassette('check_random') do
      post '/api/v1/check', body.to_json, header
    end
    last_response.must_be :not_found?
  end

  it 'should return 400 for bad JSON formatting' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = random_str(50)

    post '/api/v1/check', body, header
    last_response.must_be :bad_request?
  end
end
