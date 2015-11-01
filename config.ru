Dir.glob('./{models,helpers,controllers}/*.rb').each { |file| require file }

map('/') { run ApplicationController }
map('/api/v1/cadets') { run CadetController }
