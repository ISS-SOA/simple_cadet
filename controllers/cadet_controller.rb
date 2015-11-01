##
# Simple web service to delver codebadges functionality
class CadetController < ApplicationController
  helpers CadetHelpers

  get_cadet_username = lambda do
    content_type :json
    get_badges(params[:username]).to_json
  end

  # Web API Routes
  get '/:username.json', &get_cadet_username
end
