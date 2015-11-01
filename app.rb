require 'sinatra/base'
require_relative './model/userbadges'

##
# Simple web service to delver codebadges functionality
class CodecadetApp < Sinatra::Base
  helpers do
    def get_badges(username)
      UserBadges.new(username)
    rescue
      halt 404
    end

    def check_badges(usernames, badges)
      usernames.map do |username|
        found = UserBadges.new(username).badges.keys
        [username, badges.select { |badge| !found.include? badge }]
      end.to_h
    rescue
      halt 404
    end
  end

  get '/' do
    'Simplecadet service is up and working. See documentation at its ' \
      '<a href="https://github.com/ISS-SOA/simple_cadet/tree/soa1_basic_api">' \
      'Github repo (soa1_basic_api branch)</a>'
  end

  get '/api/v1/cadet/:username.json' do
    content_type :json
    get_badges(params[:username]).to_json
  end

  post '/api/v1/check' do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
    rescue
      halt 400
    end

    check_badges(req['usernames'], req['badges']).to_json
  end
end
