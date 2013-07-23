#!/usr/bin/env ruby
require 'yaml'
require 'pry'

def task_for_feature_file file_path
  name= file_path.match(/features\/(.*)\.feature/).captures.first
  exec = %{bundle exec cucumber "#{file_path}"}
  {"name" => name,
    "scripts" => {
    "main" => {
    "body" => exec } } }
end

ARGV[0] and File.open(ARGV[0],'w') do |file|
  file.write(
    Dir.glob("features/**/*.feature") \
    .map{|f| task_for_feature_file(f)}.to_yaml)
end
