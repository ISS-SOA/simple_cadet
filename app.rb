require 'sinatra/base'
require_relative 'cadet_helper'
require_relative 'model/tutorial'

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

  post_tutorial = lambda do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
      logger.info req
    rescue
      halt 400
    end

    tutorial = Tutorial.new(
      description: req['description'],
      usernames: req['usernames'].to_json,
      badges: req['badges'].to_json)

    if tutorial.save
      status 201
      redirect "/api/v1/tutorials/#{tutorial.id}", 303
    else
      halt 500, 'Error saving tutorial request to the database'
    end
  end

  get_tutorial = lambda do
    content_type :json
    begin
      tutorial = Tutorial.find(params[:id])
      description = tutorial.description
      usernames = JSON.parse(tutorial.usernames)
      badges = JSON.parse(tutorial.badges)
      logger.info({ id: tutorial.id, description: description }.to_json)
    rescue
      halt 400
    end

    begin
      results = check_badges(usernames, badges)
    rescue
      halt 500, 'Lookup of Codecademy failed'
    end

    { id: tutorial.id, description: description,
      usernames: usernames, badges: badges,
      missing: results }.to_json
  end

  # Web API Routes
  get '/', &get_root
  get '/api/v1/cadets/:username.json', &get_cadet_username

  get '/api/v1/tutorials/:id', &get_tutorial
  post '/api/v1/tutorials', &post_tutorial
end
