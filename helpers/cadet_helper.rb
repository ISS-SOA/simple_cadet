##
# Helpers for main Sinatra web application
module CadetHelpers
  def get_badges(username)
    UserBadges.new(username)
  rescue => e
    halt 404, e
  end
end
