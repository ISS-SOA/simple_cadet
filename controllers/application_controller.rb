require 'sinatra/base'
require 'sinatra/flash'
##
# Simple web service to delver codebadges functionality
class ApplicationController < Sinatra::Base
  helpers CadetHelpers, TutorialHelpers
  enable :sessions
  register Sinatra::Flash
  set :views, File.expand_path('../../views', __FILE__)

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
  get '/api/v1/', &get_root

  get '/api/v1/cadets/:username.json', &get_cadet_username

  get '/api/v1/tutorials/:id', &get_tutorial
  post '/api/v1/tutorials', &post_tutorial

  # Web Views Routes
  get '/' do
    haml :home
  end

  get '/cadet' do
    @username = params[:username]
    if @username
      redirect "/cadet/#{@username}"
      return nil
    end

    haml :cadet
  end

  get '/cadet/:username' do
    @username = params[:username]
    @cadet = get_badges(@username)

    if @username && @cadet.nil?
      flash[:notice] = 'username not found' if @cadet.nil?
      redirect '/cadet'
      return nil
    end

    haml :cadet
  end

  get '/tutorials' do
    @action = :create
    haml :tutorials
  end

  post '/tutorials' do
    request_url = "#{API_BASE_URI}/api/v2/tutorials"
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
      flash[:notice] = 'usernames not found'
      redirect '/tutorials'
      return nil
    end

    id = result.request.last_uri.path.split('/').last
    session[:result] = result.to_json
    session[:usernames] = usernames
    session[:badges] = badges
    session[:action] = :create
    redirect "/tutorials/#{id}"
  end

  get '/tutorials/:id' do
    if session[:action] == :create
      @results = JSON.parse(session[:result])
      @usernames = session[:usernames]
      @badges = session[:badges]
    else
      request_url = "#{API_BASE_URI}/api/v2/tutorials/#{params[:id]}"
      options =  { headers: { 'Content-Type' => 'application/json' } }
      result = HTTParty.get(request_url, options)
      @results = result
    end

    @id = params[:id]
    @action = :update
    haml :tutorials
  end

  delete '/tutorials/:id' do
    request_url = "#{API_BASE_URI}/api/v2/tutorials/#{params[:id]}"
    result = HTTParty.delete(request_url)
    flash[:notice] = 'record of tutorial deleted'
    redirect '/tutorials'
  end
end
