
def growl(message)

  growlnotify = `which growlnotify`.chomp
  title = "Watchr Test Results"
  image = message.include?('0 failures, 0 errors') ? "~/.watchr_images/passed.png" : "~/.watchr_images/failed.png"
  options = "-w -n Watchr --image '#{File.expand_path(image)}' -m '#{message}' '#{title}'"
  system %(#{growlnotify} #{options} &)

end

def run_all
  system "bundle exec rake spec"
end

def run_spec(file)
  unless File.exist?(file)
    puts "#{file} does not exist"
    return
  end

  puts "Running #{file}"
  system "rake spec SPEC=#{file}"
  puts
end

watch("spec/.*/*_spec.rb") do |match|
  run_all
  #run_spec match[0]
end

watch("app/(.*/.*).rb") do |match|
  run_all
  #run_spec %{spec/#{match[1]}_spec.rb}
end

watch("lib/.*") do |match|
  run_all
#  prefix =  ((match.to_s.split "/").last.split ".").first
#  (Dir.glob "spec/**/*_spec.rb").each do |spec|
#    run_spec spec if spec =~ (Regexp.new prefix)
#  end
end


