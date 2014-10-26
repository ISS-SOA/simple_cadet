require 'sinatra/base'
require 'codebadges'
require 'json'

##
# Simple version of original CodeCadetApp from codebadges.herokuapp.com
class CodecadetApp < Sinatra::Base
  helpers do
    def get_badges(username)
      badges_after = {
        'id'      => username,
        'type'    => 'cadet',
        'badges'  => []
      }

      user = params[:username]
      CodeBadges::CodecademyBadges.get_badges(user).each do |title, date|
        badges_after['badges'].push('id' => title, 'date' => date)
      end
      badges_after
    end

    def check_badges(usernames, badges)
      @check_info = {}
      usernames.each do |username|
        badges_found = CodeBadges::CodecademyBadges.get_badges(username).keys
        @check_info[username] = \
          badges.select { |badge| !badges_found.include? badge }
      end
      @check_info
    end
  end

  get '/api/v1/cadet/:username.json' do
    content_type :json
    get_badges(params[:username]).to_json
  end

  post '/api/v1/check' do
    content_type :json
    req = JSON.parse(request.body.read)
    usernames = req['usernames']
    badges = req['badges']
    check_badges(usernames, badges).to_json
  end
end
