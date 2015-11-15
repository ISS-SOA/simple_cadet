# \ -s puma

Dir.glob('./{models,helpers,controllers,services}/*.rb').each { |file| require file }
run ApplicationController
