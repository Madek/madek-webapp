# -*- encoding : utf-8 -*-
class MetaDatum < ActiveRecord::Base

  class << self
    def new_with_cast(*args, &block)
      if (h = args.first.try(:symbolize_keys)).is_a?(Hash) and
          (meta_key = h[:meta_key] || (h[:meta_key_id] ? MetaKey.find_by_id(h[:meta_key_id]) : nil)) and
          (klass = meta_key.meta_datum_object_type.constantize)
            raise "#{klass.name} must be a subclass of #{self.name}" unless klass < self
            klass.new_without_cast(*args, &block)
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

  after_save do
    raise "MetaDatum is abstract; instatiate a subclass" if self.reload.type == "MetaDatum" or self.reload.type == nil
  end

  belongs_to :media_resource
  belongs_to :meta_key

  validates_uniqueness_of :meta_key_id, :scope => :media_resource_id
  
  attr_accessor :keep_original_value

  scope :for_meta_terms, joins(:meta_key).where(:meta_keys => {:meta_datum_object_type => "MetaDatumMetaTerms"})

  def same_value? other_value
    raise "this method must be implemented in the derived class"
  end

########################################

  def context_warnings(context = MetaContext.core)
    # TODO raise "this method must be implemented in the derived class"
    
    definition = meta_key.meta_key_definitions.for_context(context)
    r = []
    r << "can't be blank" if value.blank? and definition.is_required
    r << "is too short (min is #{definition.length_min} characters)" if definition.length_min and (value.blank? or value.size < definition.length_min)
    r << "is too long (maximum is #{definition.length_max} characters)" if value and definition.length_max and value.size > definition.length_max
    # TODO options
    r
  end

  def context_valid?(context = MetaContext.core)
    # TODO raise "this method must be implemented in the derived class"

    context_warnings(context).empty?
  end
  
########################################

  def deserialized_value(user=nil)
    if meta_key.is_dynamic? 
      case meta_key.label
        when "owner"
          media_resource.user
        when "uploaded at"
          media_resource.created_at #old# .to_formatted_s(:date_time)
        when "copyright usage"
          copyright = media_resource.meta_data.get("copyright status").value || Copyright.default # OPTIMIZE array or single element
          copyright.usage(read_attribute(:value))
        when "copyright url"
          copyright = media_resource.meta_data.get("copyright status").value  || Copyright.default # OPTIMIZE array or single element
          copyright.url(read_attribute(:value))
        when "public access"
          media_resource.is_public?
        when "media type"
          media_resource.media_type
        when "parent media_resources"
          {:media_sets => media_resource.parent_sets.accessible_by_user(user).count}
        when "child media_resources"
          {:media_sets => media_resource.child_sets.accessible_by_user(user).count,
           :media_entries => media_resource.media_entries.accessible_by_user(user).count} if media_resource.is_a?(MediaSet)
        #when "gps"
        #  return media_resource.media_file.meta_data["GPS"]
      end
    else # aliased in the sublcasses
      value
    end
  end



end

