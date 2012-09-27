task :migrate_database do
  # Migration here 
  # deploy.migrate should work, but is buggy and is run in the _previous_ release's
  # directory, thus never runs anything? Strange.
  #deploy.migrate
  run "cd #{release_path} && RAILS_ENV='production'  bundle exec rake db:migrate"
end


