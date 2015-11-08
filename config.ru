# \ -s puma

Dir.glob('./{models,helpers,controllers}/*.rb').each { |file| require file }
run ApplicationController
