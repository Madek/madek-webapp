namespace :app do
  namespace :graph do
  
    desc "Generate Railroad diagrams (requires railroady gem)"
    task :railroad do
      `rake diagram:all` # https://github.com/preston/railroady
      `mkdir -p doc/diagrams/railroad`
      `mv doc/*_brief.svg doc/*_complete.svg doc/diagrams/railroad/`
    end
  
  end  
end  