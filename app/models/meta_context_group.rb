class MetaContextGroup < ActiveRecord::Base
  has_many :meta_contexts, :order => :position
  
  default_scope order(:position)
end
