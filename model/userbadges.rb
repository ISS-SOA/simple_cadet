require 'codebadges'
require 'json'

##
# Stores badge name and date information in a jsonifiable list
#
# Example:
#   b = BadgeList.new
#   b['Fastest Coder'] = Date.today
#   puts b.to_json
class BadgeList
  def []=(badge, date)
    @badges ||= {}
    @badges[badge] = date
  end

  def to_json
    @badges.map do |title, date|
      { 'title' => title, 'date' => date }
    end.to_json
  end
end

##
# Loads and returns full user information with scraped badges
#
# Example:
#   ub = UserBadges.new('soumya.ray')
#   puts ub.badges.to_json
#
class UserBadges
  attr_reader :username, :type, :badges

  def initialize(username, type = 'cadet')
    @username = username
    @type = type
    @badges = load_badges
  end

  def to_json
    { 'id' => @username, 'type' => @type, 'badges' => @badges }.to_json
  end

  private

  def load_badges
    badges = BadgeList.new
    CodeBadges::CodecademyBadges.new(@username).badges.each do |title, date|
      badges[title] = date
    end
  end
end
