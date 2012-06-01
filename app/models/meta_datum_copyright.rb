# -*- encoding : utf-8 -*-
 
class MetaDatumCopyright < MetaDatumBase

  belongs_to :copyright

  alias_attribute :value, :copyright
  alias_attribute :deserialized_value, :value

  def to_s
    value.map(&:to_s).join("; ")
  end

end
