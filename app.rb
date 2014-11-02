require 'sinatra/base'
require 'sinatra/namespace'
require 'codebadges'
require 'json'

##
# Simple version of CodeCadetApp from https://github.com/ISS-SOA/codecadet
class CodecadetApp < Sinatra::Base
  register Sinatra::Namespace

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

  namespace '/api/v1' do
    get '/cadet/:username.json' do
      content_type :json
      user.to_json
    end

    post '/check' do
      content_type :json
      begin
        req = JSON.parse(request.body.read)
        logger.info req
      rescue
        halt 400
      end

      usernames = req['usernames']
      badges = req['badges']
      check_badges(usernames, badges).to_json
    end
  end
end
