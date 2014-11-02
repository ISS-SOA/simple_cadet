require_relative 'spec_helper'

describe 'Getting cadet information' do
  it 'should return their badges' do
    get '/api/v1/cadet/soumya.ray.json'
    last_response.must_be :ok?
  end
end
