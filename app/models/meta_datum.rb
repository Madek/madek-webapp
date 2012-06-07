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


    def value_type_name klass_or_string
      if klass_or_string.is_a? String
        klass_or_string
      else
        klass_or_string.name
      end 
      .gsub(/^MetaDatum/,"").underscore
    end
  end

  after_save do
    raise "MetaDatum is abstract; instatiate a subclass" if self.reload.type == "MetaDatum" or self.reload.type == nil
  end

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

  def deserialized_value(user=nil)
    if meta_key.is_dynamic? 
      case meta_key.label
        when "owner"
          return media_resource.user
        when "uploaded at"
          return media_resource.created_at #old# .to_formatted_s(:date_time)
        when "copyright usage"
          copyright = media_resource.meta_data.get("copyright status").deserialized_value.first || Copyright.default # OPTIMIZE array or single element
          return copyright.usage(read_attribute(:value))
        when "copyright url"
          copyright = media_resource.meta_data.get("copyright status").deserialized_value.first  || Copyright.default # OPTIMIZE array or single element
          return copyright.url(read_attribute(:value))
        when "public access"
          return media_resource.is_public?
        when "media type"
          return media_resource.media_type
        #when "gps"
        #  return media_resource.media_file.meta_data["GPS"]
      end
    else # aliased in the sublcasses
      value
    end
  end



end


