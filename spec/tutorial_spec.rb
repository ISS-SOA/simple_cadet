require_relative 'spec_helper'
require 'json'

describe 'Checking many users for badges' do
  before do
    Tutorial.delete_all
  end

  it 'should find missing badges' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      description: 'Check valid users and badges',
      usernames: ['soumya.ray', 'chenlizhan'],
      badges: ['Object-Oriented Programming II']
    }

    # Check redirect URL from post request
    post '/api/v1/tutorials', body.to_json, header
    last_response.must_be :redirect?
    next_location = last_response.location
    next_location.must_match %r{api\/v1\/tutorials\/\d+}

    # Check if request parameters are stored in ActiveRecord data store
    tut_id = next_location.scan(%r{tutorials\/(\d+)}).flatten[0].to_i
    save_tutorial = Tutorial.find(tut_id)
    JSON.parse(save_tutorial[:usernames]).must_equal body[:usernames]
    JSON.parse(save_tutorial[:badges]).must_include body[:badges][0]

    # Check if redirect works
    VCR.use_cassette('tutorial_happy') do
      follow_redirect!
    end
    last_request.url.must_match %r{api\/v1\/tutorials\/\d+}

    # Check if redirected response has results
    JSON.parse(last_response.body).count.must_be :>, 0
  end

  it 'should return 404 for unknown users' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      description: 'Check invalid users and invalid badges',
      usernames: [random_str(15), random_str(15)],
      badges: [random_str(30)]
    }

    post '/api/v1/tutorials', body.to_json, header

    last_response.must_be :redirect?
    VCR.use_cassette('tutorial_sad_404') do
      follow_redirect!
    end
    last_response.must_be :not_found?
  end

  it 'should return 400 for bad JSON formatting' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = random_str(50)

    post '/api/v1/tutorials', body, header
    last_response.must_be :bad_request?
  end
end
