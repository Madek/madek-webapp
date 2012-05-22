# -*- encoding : utf-8 -*-
 
class MetaDatumString < MetaDatum

  alias_attribute :value, :string

  def set_value_before_save
=begin #Thomas#
    puts "****** MetaDatumString#set_value_before_save ********"
=end
  end

  def to_s
    string
  end

end
