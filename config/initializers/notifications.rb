#This goes in the Rails 3 config/initializers directory
# Note: this has not been tested

 ActiveSupport::Notifications.subscribe /^sql\./ do |*args|
   File.open('index_tester','a') do |f|
     f.print "#{args[0]}|"
     f.print "#{args[1].strftime('%Y-%m-%d %H:%M:%S')}|"
     f.print "#{args[2].strftime('%Y-%m-%d %H:%M:%S')}|"
     f.print "#{args[2]-args[1]}|"
     f.print "#{args[4][:name]}|"
     f.print "#{args[4][:sql].strip.gsub(/\n/,'').squeeze(' ')}"
     f.puts
 end
