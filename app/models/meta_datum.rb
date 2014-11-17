# -*- encoding : utf-8 -*-
class MetaDatum < ActiveRecord::Base

  UUID_V4_REGEXP= /^\w{8}-\w{4}-4\w{3}-\w{4}-\w{12}$/

  class << self
    def new_with_cast(*args, &block)
      if (h = args.first.try(:symbolize_keys)).is_a?(Hash) and
          (meta_key = h[:meta_key] || (h[:meta_key_id] ? MetaKey.find_by_id(h[:meta_key_id]) : nil)) and
          (klass = meta_key.meta_datum_object_type.constantize)
            #raise "#{klass.name} must be a subclass of #{self.name}" unless klass < self
            # NOTE the value setter has to be invoked after the instantiation (not during)
            value = args.first.delete("value") || args.first.delete(:value)
            r = klass.new_without_cast(*args, &block)
            r.value = value if value
            r
      elsif self < MetaDatum
        new_without_cast(*args, &block)
      else
        raise "MetaDatum is abstract; instatiate a subclass"
      end
    end
    alias_method_chain :new, :cast

    def value_type_name klass_or_string
      if klass_or_string.is_a? String
        klass_or_string
      else
        klass_or_string.name
      end 
      .gsub(/^MetaDatum/,"").underscore
    end
  end


  ########################################

  belongs_to :meta_key

  belongs_to :media_entry
  belongs_to :collection
  belongs_to :filter_set


  ########################################

  
########################################

end

