##
# Helpers for main Sinatra web application
module TutorialHelpers
  def check_badges(usernames, badges)
    usernames.map do |username|
      found = UserBadges.new(username).badges.keys
      [username, badges.select { |badge| !found.include? badge }]
    end.to_h
  rescue
    halt 404
  end
end
