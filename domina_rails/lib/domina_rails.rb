require 'pry'
module DominaRails
  PWD = File.expand_path("./")
  APP_ROOT = File.expand_path("../../../",__FILE__)
  raise "dci commands must be called from the application root directory" unless PWD == APP_ROOT
end
