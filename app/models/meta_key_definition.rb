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

  def additional_fields?
    previous_changes.has_key?('meta_key_id') && meta_key_string?
  end

  def meta_key_string?
    meta_key.meta_datum_object_type == 'MetaDatumString'
  end
  
  def is_multiline?
    return nil unless self.meta_key_string?
    definition = self
    case
      # explicit config:
      when !definition.input_type.nil?
        if definition.input_type != 'text_area' then false else true end
      # otherwise implicit config:
      when !definition.length_max.nil?
        if definition.length_max >= 255 then true else false end
      # default
      else 
        true
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
