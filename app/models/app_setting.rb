class AppSetting < ActiveRecord::Base
  serialize :sitemap, JSON
end
