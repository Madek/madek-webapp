# -*- encoding : utf-8 -*-
#= MetaKeyDefinition
#
# Our association object between a Context and a MetaKey, with a serialized value.
#
# A meta key definition provides a description and label for a particular meta-key in a particular context.

class MetaKeyDefinition < ActiveRecord::Base

  belongs_to    :context, foreign_key: :context_id
  belongs_to    :meta_key

  default_scope lambda{order("meta_key_definitions.position ASC")}

  before_create do 
    self.position = context.next_position  unless self.position
  end

  enum input_type: [ :text_field, :text_area ]

#########################

end
