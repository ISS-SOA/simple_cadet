require_relative 'spec_helper'
require_relative 'support/story_helpers'
require 'json'

describe 'SimpleCadet Stories' do
  include StoryHelpers

  describe 'Getting the root of the service' do
    it 'Should return ok' do
      get '/'
      last_response.must_be :ok?
      last_response.body.must_match(/simplecadet/i)
    end
  end

  describe 'Getting cadet information' do
    it 'should return their badges' do
      get '/api/v1/cadet/soumya.ray.json'
      last_response.must_be :ok?
    end

    it 'should return 404 for unknown user' do
      get "/api/v1/cadet/#{random_str(20)}.json"
      last_response.must_be :not_found?
    end
  end

  describe 'Checking users for badges' do
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

      post '/api/v1/tutorials', body.to_json, header
      last_response.must_be :redirect?
      follow_redirect!
      last_request.url.must_match /api\/v1\/tutorials\/\d+/
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
      follow_redirect!
      last_response.must_be :not_found?
    end

    it 'should return 400 for bad JSON formatting' do
      header = { 'CONTENT_TYPE' => 'application/json' }
      body = random_str(50)

      post '/api/v1/tutorials', body, header
      last_response.must_be :bad_request?
    end
  end
end
