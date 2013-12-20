class FullText < ActiveRecord::Base
  self.primary_key= 'media_resource_id'
  
  belongs_to :media_resource

end
