require 'sinatra/base'
require_relative 'cadet_helper'

##
# Simple web service to delver codebadges functionality
class CodecadetApp < Sinatra::Base
  helpers CadetHelpers

  configure :production, :development do
    enable :logging
  end

  get_root = lambda do
    'Simplecadet service is up and working. See documentation at its ' \
      '<a href="https://github.com/ISS-SOA/simple_cadet/tree/soa1_basic_api">' \
      'Github repo (soa1_basic_api branch)</a>'
  end

  get_cadet_username = lambda do
    content_type :json
    get_badges(params[:username]).to_json
  end

  post_check = lambda do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
      logger.info req
    rescue
      halt 400
    end

    check_badges(req['usernames'], req['badges']).to_json
  end

  # Web API Routes
  get '/', &get_root
  get '/api/v1/cadet/:username.json', &get_cadet_username
  post '/api/v1/check', &post_check
end
