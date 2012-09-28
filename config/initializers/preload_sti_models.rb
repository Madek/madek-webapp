#sellittf#
# TODO remove this initializer when solved in a generic way
# https://github.com/rails/rails/issues/3364
# http://www.christopherbloom.com/2012/02/01/notes-on-sti-in-rails-3-0/

if Rails.env.development?
  # Make sure we preload the parent and children classes in development
  
  #Rails.application.eager_load!
  %w[media_resource media_set filter_set].each do |c|
    require_dependency File.join("app","models","#{c}.rb")
  end
end
