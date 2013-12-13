class MetaContextGroup < ActiveRecord::Base
  has_many :meta_contexts, lambda{order(:position)}
  
  default_scope lambda{order(:position)}

  before_create do |meta_context_group|
    meta_context_group.position ||= MetaContextGroup.maximum(:position).to_i + 1
  end

  before_destroy do |meta_context_group|
    MetaContext.where(meta_context_group_id: meta_context_group.id).each do |context|
      context.update_attributes meta_context_group: nil
    end
  end

  scope :sorted_by_position, lambda{order(:position, :id)}
end
