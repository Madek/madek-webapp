# -*- encoding : utf-8 -*-
class MetaDatum < ActiveRecord::Base


  class << self
    def new_with_cast(*args, &block)
      # TODO it should be possible to give type as a Class
      if (h = args.first).is_a? Hash and 
        (type = h[:type] || h['type']) and 
        (klass = type.constantize) != self
        raise "#{klass.name} must be a subclass of #{self.name}"  unless klass < self  
        return klass.new(*args, &block)
      end
      new_without_cast(*args,&block)
    end

    alias_method_chain :new, :cast
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

end


