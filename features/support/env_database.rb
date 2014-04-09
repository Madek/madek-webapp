Before do |scenario|

  ExceptionHelper.log_and_reraise do
    DBHelper.truncate_tables
    DBHelper.load_data Rails.root.join('db','personas.data.psql')
  end

end
