# -*- encoding : utf-8 -*-
class MetaDatum < ActiveRecord::Base


  class << self
    def new_with_cast(*args, &block)

      if (h = args.first).is_a? Hash 
        if (type = h[:type] || h['type']) and (klass = type.constantize) != self
          return call_new_with_subclass_check klass, args, block
        elsif meta_key = h[:meta_key] || h['meta_key'] and (klass = meta_key.meta_datum_object_type.constantize) != self
          return call_new_with_subclass_check klass, args, block
        end
      end

      raise "MetaDatum is abstract; instatiate a subclass" unless self < MetaDatum
      new_without_cast(*args,&block)
    end

    def call_new_with_subclass_check klass, args, block
      raise "#{klass.name} must be a subclass of #{self.name}"  unless klass < self  
      klass.new(*args, &block)
    end

    alias_method_chain :new, :cast
  end

  after_save do
    raise "MetaDatum is abstract; instatiate a subclass" if self.reload.type == "MetaDatum" or self.reload.type == nil
  end

  set_table_name :meta_data

  belongs_to :media_resource
  belongs_to :meta_key

  scope :for_meta_terms, joins(:meta_key).where(:meta_keys => {:object_type => "MetaTerm"})

  def same_value? other_value
    raise "this method must be implemented in the derived class"
  end

  def context_warnings(context = MetaContext.core)
    raise "this method must be implemented in the derived class"
  end

  def context_valid?(context = MetaContext.core)
    raise "this method must be implemented in the derived class"
  end

  def deserialized_value
    raise "this method must be implemented in the derived class"
  end

end


