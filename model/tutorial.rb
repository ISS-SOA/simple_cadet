require 'sinatra'
require 'sinatra/activerecord'
require_relative '../config/environments'

class Tutorial < ActiveRecord::Base
end
