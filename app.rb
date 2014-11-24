require 'sinatra/base'
require 'codebadges'
require 'json'
require_relative 'model/tutorial'

require 'haml'
require 'sinatra/flash'

require 'httparty'

##
# Simple version of CodeCadetApp from https://github.com/ISS-SOA/codecadet
class CodecadetApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash
  use Rack::MethodOverride

  configure :production, :development do
    enable :logging
  end

  configure :development do
    set :session_secret, "something"    # ignore if not using shotgun in development
  end

  API_BASE_URI = 'http://localhost:9393'

  helpers do
    def user
      username = params[:username]
      return nil unless username

      badges_after = { 'id' => username, 'type' => 'cadet', 'badges' => [] }

      begin
        CodeBadges::CodecademyBadges.get_badges(username).each do |title, date|
          badges_after['badges'].push('id' => title, 'date' => date)
        end
        badges_after
      rescue
        nil
      end
    end

    def check_badges(usernames, badges)
      @incomplete = {}
      begin
        usernames.each do |username|
          badges_found = CodeBadges::CodecademyBadges.get_badges(username).keys
          @incomplete[username] = \
                  badges.reject { |badge| badges_found.include? badge }
        end
      rescue
        halt 404
      else
        @incomplete
      end
    end

    def current_page?(path = ' ')
      path_info = request.path_info
      path_info += ' ' if path_info == '/'
      request_path = path_info.split '/'
      request_path[1] == path
    end
  end

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
    @cadet = user
    @username = params[:username]

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


  # API handlers
  get '/api/v1/?' do
    'Simplecadet api/v2 is deprecated: please use <a href="/api/v2/">api/v2</a>'
  end

  get '/api/v2/?' do
    'Simplecadet api/v2 is up and working'
  end

  get '/api/v2/cadet/:username.json' do
    content_type :json
    user.nil? ? halt(404) : user.to_json
  end

  delete '/api/v2/tutorials/:id' do
    tutorial = Tutorial.destroy(params[:id])
  end

  post '/api/v2/tutorials' do
    content_type :json

    body = request.body.read
    logger.info body

    begin
      req = JSON.parse(body)
      logger.info req
    rescue Exception => e
      puts e.message
      halt 400
    end

    tutorial = Tutorial.new
    tutorial.description = req['description'].to_json
    tutorial.usernames = req['usernames'].to_json
    tutorial.badges = req['badges'].to_json

    if tutorial.save
      redirect "/api/v2/tutorials/#{tutorial.id}"
    end
  end

  get '/api/v2/tutorials/:id' do
    content_type :json
    logger.info "GET /api/v2/tutorials/#{params[:id]}"
    begin
      @tutorial = Tutorial.find(params[:id])
      usernames = JSON.parse(@tutorial.usernames)
      badges = JSON.parse(@tutorial.badges)
      logger.info({ usernames: usernames, badges: badges }.to_json)
    rescue
      halt 400
    end

    result = check_badges(usernames, badges).to_json
    logger.info "result: #{result}\n"
    result
  end
end
