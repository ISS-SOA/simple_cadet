require 'sinatra/base'
require 'codebadges'
require 'json'
require_relative 'model/tutorial'

require 'haml'
require 'sinatra/flash'

##
# Simple version of CodeCadetApp from https://github.com/ISS-SOA/codecadet
class CodecadetApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  configure :production, :development do
    enable :logging
  end

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
    end

    haml :cadet
  end



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

  post '/api/v2/tutorials' do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
      logger.info req
    rescue
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
    begin
      @tutorial = Tutorial.find(params[:id])
      usernames = JSON.parse(@tutorial.usernames)
      badges = JSON.parse(@tutorial.badges)
      logger.info({ usernames: usernames, badges: badges }.to_json)
    rescue
      halt 400
    end

    check_badges(usernames, badges).to_json
  end
end
