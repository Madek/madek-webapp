task :clear_cache do
  # We have to run it this way (in a subshell) because Rails.cache is not available
  # in Rake tasks, otherwise we could stick a task into lib/tasks/madek.bundle exec rake
  run "cd #{release_path} && RAILS_ENV=production  bundle exec rails runner 'Rails.cache.clear'"
end
