require 'virtus'
require 'active_model'

class CheckTutorialFromAPI
  def initialize(api, params_h)
    @request_url = "#{api.api_server}/#{api.api_ver}/tutorials"
    @options =  { body: params_h.to_json,
                  headers: { 'Content-Type' => 'application/json' }
                }
  end

  def call
    result = HTTParty.post(@request_url, @options)
    puts result
    tutorial_result = TutorialResult.new(result)
    tutorial_result.code = result.code
    tutorial_result
  end
end

##
# Value object for results from searching a tutorial set for missing badges
class TutorialResult
  include Virtus.model

  attribute :code
  attribute :id
  attribute :usernames
  attribute :badges
  attribute :missing

  def to_json
    to_hash.to_json
  end
end

##
# Attribute for form objects of TutorialForm
class ArrayOfNames < Virtus::Attribute
  def coerce(value)
    value.is_a?(String) ? value.split("\r\n") : value
  end
end

##
# Form object TutorialForm
class TutorialForm
  include Virtus.model
  include ActiveModel::Validations

  attribute :usernames, ArrayOfNames
  attribute :badges, ArrayOfNames

  validates :usernames, presence: true
  validates :badges, presence: true
end
