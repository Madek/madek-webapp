require 'composite_primary_keys'

module VisualizationJsonSerializer
  class << self

    def load(data)
      begin
        JSON.parse data
      rescue
        {}
      end
    end

    def dump(obj)
      begin
        obj.to_json
      rescue
        "{}"
      end
    end

  end
end

class Visualization < ActiveRecord::Base
   self.primary_keys =  :user_id, :resource_identifier
   serialize :control_settings, VisualizationJsonSerializer
   serialize :layout, VisualizationJsonSerializer

   def self.find_or_falsy user_id,resource_identifier
     begin
       Visualization.find user_id,resource_identifier
     rescue 
       nil
     end
   end
end
