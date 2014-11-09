require 'rake/testtask'
require './app'
require 'sinatra/activerecord/rake'

task :default => :spec

desc "Run all tests"
Rake::TestTask.new(name=:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
end
