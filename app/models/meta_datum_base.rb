# -*- encoding : utf-8 -*-
class MetaDatumBase < ActiveRecord::Base

  class << self
    def new_with_cast(*a, &b)
      
      if (h = a.first).is_a? Hash and (type = h[:type] || h['type']) and (klass = type.constantize) != self
        raise "wtF hax!!"  unless klass < self  # klass should be a descendant of us
        return klass.new(*a, &b)
      end
      new_without_cast(*a,&b)
    end

    alias_method_chain :new, :cast
  end



  self.table_name = :meta_data

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


