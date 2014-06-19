class ContextGroup < ActiveRecord::Base
  has_many :contexts, lambda{order(:position)}
  
  default_scope lambda{order(:position)}

  before_create do |context_group|
    context_group.position ||= ContextGroup.maximum(:position).to_i + 1
  end

  before_destroy do |context_group|
    Context.where(context_group_id: context_group.id).each do |context|
      context.update_attributes context_group: nil
    end
  end

  scope :sorted_by_position, lambda{order(:position, :id)}

  accepts_nested_attributes_for :contexts

  def to_s
    name
  end
end
