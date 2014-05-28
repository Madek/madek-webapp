class Visualization < ActiveRecord::Base
   serialize :control_settings, JsonSerializer
   serialize :layout, JsonSerializer

   def self.find_or_falsy user_id,resource_identifier
     Visualization.find_by user_id: user_id, resource_identifier: resource_identifier 
   end
end
