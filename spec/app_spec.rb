require_relative 'spec_helper'

describe 'Getting cadet information' do
  it 'should return their badges' do
    get '/api/v1/cadet/soumya.ray.json'
    last_response.must_be :ok?
  end

  it 'should handle unknown user' do
    random_name = (0..20).map { ('a'..'z').to_a[rand(26)] }.join
    get "/api/v1/cadet/#{random_name}.json"
    last_response.must_be :not_found?
  end
end
