# -*- encoding : utf-8 -*-
#= MetaKeyDefinition
#
# Our association object between a MetaContext and a MetaKey, with a serialized value.
#
# A meta key definition provides a description and label for a particular meta-key in a particular context.

class MetaKeyDefinition < ActiveRecord::Base

  belongs_to    :meta_context, foreign_key: :meta_context_name
  belongs_to    :meta_key

  validates_presence_of :meta_key 
  validate do |record|
    if record.meta_context.is_user_interface?
      record.errors.add(:base, "key_map has to be blank") unless record.key_map.blank? 
    else
      record.errors.add(:base, "key_map can't be blank") if record.key_map.blank?
    end
  end

  default_scope lambda{order("meta_key_definitions.position ASC")}

  before_create do 
    self.position = meta_context.next_position  unless self.position
  end

#########################

  [:label, :description, :hint].each do |name|
    belongs_to name, :class_name => "MetaTerm"
    define_method "#{name}=" do |h|
      write_attribute("#{name}_id", MetaTerm.find_or_create(h).try(:id))
    end
  end

end
