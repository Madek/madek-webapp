class AppSettings < ActiveRecord::Base

  serialize :footer_links, JsonSerializer

end
