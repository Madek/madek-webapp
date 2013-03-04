require 'composite_primary_keys'

class Visualization < ActiveRecord::Base
   self.primary_keys =  :user_id, :resource_identifier
   serialize :control_settings, JsonSerializer
   serialize :layout, JsonSerializer

   def self.find_or_falsy user_id,resource_identifier
     Visualization.find user_id,resource_identifier rescue nil
   end
end
