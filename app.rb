require 'sinatra/base'
require 'codebadges'
require 'json'

class CodecadetApp < Sinatra::Base
  helpers do
    def get_badges(username)
      badges_after = {
        'id'      => username,
        'type'    => 'cadet',
        'badges'  => []
      }

      CodeBadges::CodecademyBadges.get_badges(params[:username]).each do |title, date|
        badges_after['badges'].push('id' => title, 'date' => date)
      end
      badges_after
    end
  end

  get '/api/v1/cadet/:username.json' do
    content_type :json
    get_badges(params[:username]).to_json
  end
end
