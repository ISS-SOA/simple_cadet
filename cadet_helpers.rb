require_relative './model/userbadges'

##
# Helpers for main Sinatra web application
module CadetHelpers
  def get_badges(username)
    UserBadges.new(username)
  rescue
    halt 404
  end

  def check_badges(usernames, badges)
    @check_info = {}
    usernames.map do |username|
      found = UserBadges.new(username).badges.keys
      [username, badges.select { |badge| !found.include? badge }]
    end.to_h
  rescue
    halt 404
  end
end
