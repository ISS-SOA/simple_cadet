require 'sinatra/base'
require 'codebadges'
require 'json'
require_relative 'model/tutorial'

##
# Simple version of CodeCadetApp from https://github.com/ISS-SOA/codecadet
class CodecadetApp < Sinatra::Base

  configure :production, :development do
    enable :logging
  end

  helpers do
    def user
      username = params[:username]
      badges_after = { 'id' => username, 'type' => 'cadet', 'badges' => [] }

      begin
        CodeBadges::CodecademyBadges.get_badges(username).each do |title, date|
          badges_after['badges'].push('id' => title, 'date' => date)
        end
      rescue
        halt 404
      else
        badges_after
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
  end

  get '/' do
    'Simplecadet api/v1 is up and working'
  end

  get '/api/v1/cadet/:username.json' do
    content_type :json
    user.to_json
  end

  post '/api/v1/tutorials' do
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

    if tutorial.save!
      status 201
      redirect "/api/v1/tutorials/#{tutorial.id}"
    end
  end

  get '/api/v1/tutorials/:id' do
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
