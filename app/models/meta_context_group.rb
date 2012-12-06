class MetaContextGroup < ActiveRecord::Base
  has_many :meta_contexts, :order => :position
  
  default_scope order(:position)

  before_create do |meta_context_group|
    meta_context_group.position ||= MetaContextGroup.maximum(:position) + 1
  end

  scope :sorted_by_position, order(:position, :id)
end
