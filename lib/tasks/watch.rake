
namespace :watch do

  desc "Watch for changes/specs to be run"
  task :spec do
    sh %{bundle exec watchr .watch_spec.rb}
  end

end
