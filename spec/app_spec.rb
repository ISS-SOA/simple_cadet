require_relative 'spec_helper'
require 'json'

describe 'Getting the root of the API' do
  it 'Should return ok' do
    get '/api/v1'
    last_response.must_be :ok?
    last_response.body.must_match(/simplecadet/i)
  end
end
