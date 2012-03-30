class MetaContextGroup < ActiveRecord::Base
  has_many :meta_contexts
  
  default_scope order(:position)
end
