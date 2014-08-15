# -*- encoding : utf-8 -*-
#= MetaKeyDefinition
#
# Our association object between a Context and a MetaKey, with a serialized value.
#
# A meta key definition provides a description and label for a particular meta-key in a particular context.

class MetaKeyDefinition < ActiveRecord::Base

  belongs_to    :context, foreign_key: :context_id
  belongs_to    :meta_key

  default_scope { order("position ASC") }

  before_create do 
    self.position = context.next_position  unless self.position
  end

  enum input_type: [ :text_field, :text_area ]

#########################

  def move_up
    regenerate_positions
    if (previous = MetaKeyDefinition.find_by(context_id: context.id, position: position - 1)).present?
      MetaKeyDefinition.transaction do
        previous.update_attribute(:position, position)
        self.update_attribute(:position, position - 1)
      end
    end
  end

  def move_down
    regenerate_positions
    if (next_elem = MetaKeyDefinition.find_by(context_id: context.id, position: position + 1)).present?
      MetaKeyDefinition.transaction do
        next_elem.update_attribute(:position, position)
        self.update_attribute(:position, position + 1)
      end
    end
  end

  private

  def regenerate_positions
    MetaKeyDefinition.transaction do
      MetaKeyDefinition.where(context_id: context.id).each_with_index do |meta_key_definition, index|
        meta_key_definition.update_attribute(:position, index)
      end
    end
    reload
  end
end
