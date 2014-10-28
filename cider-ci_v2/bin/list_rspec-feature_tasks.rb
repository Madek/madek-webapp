#!/usr/bin/env ruby
require 'yaml'
require 'pry'

def task_for_rspec_file file_path
  name= file_path.match(/spec\/(.*)_spec\.rb/).captures.first.gsub(/\//,' ')
  exec = %{DISPLAY=":$XVNC_PORT" bundle exec rspec "#{file_path}"}
  {"name" => name,
    "scripts" => {
    "rspec" => {
    "body" => exec } } }
end

STDOUT.write(
  {"tasks" => 
   Dir.glob("spec/**/*_spec.rb").select{|name| name =~ /spec\/feature/ } \
     .map{|f| task_for_rspec_file(f)}}.to_yaml)
