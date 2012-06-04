# -*- encoding : utf-8 -*-
 
class MetaDatumCopyright < MetaDatum

  belongs_to :copyright

  alias_attribute :value, :copyright
  alias_attribute :deserialized_value, :value

  def to_s
    value.to_s
  end

end
