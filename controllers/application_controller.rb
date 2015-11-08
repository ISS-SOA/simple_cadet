require 'sinatra/base'
require 'sinatra/flash'
require 'httparty'
require 'hirb'
##
# Simple web service to delver codebadges functionality
class ApplicationController < Sinatra::Base
  helpers CadetHelpers, TutorialHelpers
  enable :sessions
  register Sinatra::Flash
  use Rack::MethodOverride

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  configure do
    Hirb.enable
    set :session_secret, 'something'
    set :api_ver, 'api/v1'
  end

  configure :development, :test do
    set :api_server, 'http://localhost:9393'
  end

  configure :production do
    set :api_server, 'http://simplecadet.herokuapp.com'
  end

  configure :production, :development do
    enable :logging
  end

  helpers do
    def current_page?(path = ' ')
      path_info = request.path_info
      path_info += ' ' if path_info == '/'
      request_path = path_info.split '/'
      request_path[1] == path
    end
  end

  api_get_root = lambda do
    'Simplecadet service is up and working. See documentation at its ' \
      '<a href="https://github.com/ISS-SOA/simple_cadet/tree/soa1_basic_api">' \
      'Github repo (soa1_basic_api branch)</a>'
  end

  api_get_cadet_username = lambda do
    content_type :json
    get_badges(params[:username]).to_json
  end

  api_post_tutorial = lambda do
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
      redirect "/#{settings.api_ver}/tutorials/#{tutorial.id}", 303
    else
      halt 500, 'Error saving tutorial request to the database'
    end
  end

  api_get_tutorial = lambda do
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

  api_delete_tutorial = lambda do
    tutorial = Tutorial.destroy(params[:id])
    status(tutorial > 0 ? 200 : 404)
  end

  # Web API Routes
  get '/api/v1/?', &api_get_root
  get '/api/v1/cadets/:username.json', &api_get_cadet_username
  get '/api/v1/tutorials/:id', &api_get_tutorial
  post '/api/v1/tutorials/?', &api_post_tutorial
  delete '/api/v1/tutorials/:id', &api_delete_tutorial

  app_get_root = lambda do
    haml :home
  end

  app_get_cadet = lambda do
    @username = params[:username]
    if @username
      redirect "/cadet/#{@username}"
      return nil
    end

    haml :cadet
  end

  app_get_cadet_username = lambda do
    @username = params[:username]
    @cadet = get_badges(@username)

    if @username && @cadet.nil?
      flash[:notice] = 'username not found' if @cadet.nil?
      redirect '/cadet'
      return nil
    end

    haml :cadet
  end

  app_get_tutorials = lambda do
    @action = :create
    haml :tutorials
  end

  app_post_tutorials = lambda do
    request_url = "#{settings.api_server}/#{settings.api_ver}/tutorials"
    usernames = params[:usernames].split("\r\n")
    badges = params[:badges].split("\r\n")
    params_h = {
      usernames: usernames,
      badges: badges
    }

    options =  {  body: params_h.to_json,
                  headers: { 'Content-Type' => 'application/json' }
               }

    result = HTTParty.post(request_url, options)

    if (result.code != 200)
      flash[:notice] = 'Could not process your request'
      redirect '/tutorials'
      return nil
    end

    id = result.request.last_uri.path.split('/').last
    session[:results] = result.to_json
    session[:action] = :create
    redirect "/tutorials/#{id}"
  end

  app_get_tutorials_id = lambda do
    if session[:action] == :create
      @results = JSON.parse(session[:results])
    else
      request_url = "#{settings.api_server}/#{settings.api_ver}/tutorials/#{params[:id]}"
      options =  { headers: { 'Content-Type' => 'application/json' } }
      @results = HTTParty.get(request_url, options)
      if @results.code != 200
        flash[:notice] = 'cannot find record of tutorial'
        redirect '/tutorials'
      end
    end

    @id = params[:id]
    @action = :update
    @usernames = @results['usernames']
    @badges = @results['badges']
    haml :tutorials
  end

  app_delete_tutorials_id = lambda do
    request_url = "#{settings.api_server}/#{settings.api_ver}/tutorials/#{params[:id]}"
    HTTParty.delete(request_url)
    flash[:notice] = 'record of tutorial deleted'
    redirect '/tutorials'
  end

  # Web App Views Routes
  get '/', &app_get_root
  get '/cadet', &app_get_cadet
  get '/cadet/:username', &app_get_cadet_username
  get '/tutorials', &app_get_tutorials
  post '/tutorials', &app_post_tutorials
  get '/tutorials/:id', &app_get_tutorials_id
  delete '/tutorials/:id', &app_delete_tutorials_id
end
