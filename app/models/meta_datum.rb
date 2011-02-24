# -*- encoding : utf-8 -*-
#= MetaDatum
# The Association class for relating a Resource (e.g. a MediaEntry) to a MetaKey and a value for that key.
# 
# Values are serialized objects (but should we be using composed_of instead?)
class MetaDatum < ActiveRecord::Base
  
  belongs_to :resource, :polymorphic => true
  belongs_to :meta_key

  serialize :value

  validates_uniqueness_of :meta_key_id, :scope => [:resource_type, :resource_id]
  validates_presence_of :resource_type, :resource_id, :meta_key_id, :value

  before_save do |record|
    case record.meta_key.object_type
      when nil, "Meta::Country"
      #working here# TODO set String for 'subject' key
      #when "String"
      #  record.value = record.value.split(',')
      else
        klass = record.meta_key.object_type.constantize
        values = case klass.name
                    when "Person"
                      klass.split(Array(record.value))
                    when "Meta::Date"
                      record.value.to_s.split(' - ') # Needs to be a string because other objects might not have .split, which breaks
                                                     # parsing the date. Mostly a safety measure, but also to make migration from 0.1.2 to 0.1.3 work.
                    else
                      Array(record.value)
                 end
        # TODO Person.suspend_delta
        record.value = values.map do |v|
                          if v.is_a?(Fixnum) or (v.respond_to?(:match) and !!v.match(/\A[+-]?\d+\Z/)) # TODO patch to String#is_numeric? method
                            r = klass.where(:id => v).first
                          elsif klass == Copyright
                            r = record.value  
                          elsif klass == Person
                            firstname, lastname = klass.parse(v)
                            r = klass.find_or_create_by_firstname_and_lastname(:firstname => firstname.try(:capitalize), :lastname => lastname.try(:capitalize)) if firstname or lastname
                          elsif klass == Keyword
                            # 2210
                            conditions = [[]]
                            LANGUAGES.each do |lang|
                              conditions.first << "#{lang} = ?"
                              conditions << v
                            end
                            conditions[0] = conditions.first.join(" OR ") 
                            term = Meta::Term.where(conditions).first
                            
                            term ||= begin
                              h = {}
                              LANGUAGES.each do |lang|
                                h[lang] = v
                              end
                              Meta::Term.create(h) 
                            end

                            user = resource.editors.latest || (resource.respond_to?(:user) ? resource.user : nil)
                            r = Keyword.create(:meta_term => term, :user => user)
                            
                            # TODO delete keywords records anymore referenced  
                          elsif klass == Meta::Date
                            r = klass.parse(v)
                          end
                          
                          (r ? r.id : nil )
                      end
        record.value.compact!
    end
  end

##########################################################

  alias_method :orig_meta_key=, :meta_key=
  def meta_key=(key)
    self.orig_meta_key = if key.is_a? MetaKey
      key
    else
      MetaKey.find_or_create_by_label(key.downcase)
      #new# MetaKey.find_label(key.downcase)
    end
  end
  
  def to_s
    v = deserialized_value
    if v.is_a?(Array)
      return v.join(', ')
    else
      return v.to_s
    end
  end

  # some meta_keys don't store values,
  # then the returned value could be a stored one or dynamically computed
#working here# TODO deserialized_value #value
  def deserialized_value
     if meta_key.is_dynamic?
      case meta_key.label
        when "uploaded by"
          return resource.user
        when "uploaded at"
          return resource.created_at #old# .to_formatted_s(:date_time) # TODO resource.upload_session.created_at ??
        when "copyright usage"
          copyright = resource.meta_data.get("copyright status").deserialized_value.first || Copyright.default # OPTIMIZE array or single element
          return copyright.usage(read_attribute(:value))
        when "copyright url"
          copyright = resource.meta_data.get("copyright status").deserialized_value.first  || Copyright.default # OPTIMIZE array or single element
          return copyright.url(read_attribute(:value))
        when "public access"
          return resource.acl?(:view, :all)
        when "media type"
          return resource.media_type
        #when "gps"
        #  return resource.media_file.meta_data["GPS"]
      end
    else
      case meta_key.object_type
        when nil, "Meta::Country"
          return read_attribute(:value)
        else
          klass = meta_key.object_type.constantize
          return Array(read_attribute(:value)).map do |v| # OPTIMIZE 0,1,n limits, return single value if it isn't an Array
            Rails.cache.fetch("#{klass}/#{v}", :expires_in => 10.minutes) do
              #old# klass.find(v) if v
              klass.where(:id => v).first if v
              # TODO return "Reference not found" instead of nil ??
            end
          end.compact
      end
    end
  end

#old#
#  # compares two objects in order to sort them
#  def <=>(other)
#    self.meta_key.label <=> other.meta_key.label
#  end
  
##########################################################

  def context_warnings(context = MetaContext.core)
    @context_warnings ||= {}
    unless @context_warnings[context.id]
      @context_warnings[context.id] = []
      
      definition = meta_key.meta_key_definitions.for_context(context)
      meta_field = definition.meta_field

      @context_warnings[context.id] << "can't be blank" if value.blank? and meta_field.is_required
      @context_warnings[context.id] << "is too short (min is #{meta_field.length_min} characters)" if meta_field.length_min and (value.blank? or value.size < meta_field.length_min)
      @context_warnings[context.id] << "is too long (maximum is #{meta_field.length_max} characters)" if value and meta_field.length_max and value.size > meta_field.length_max
      # TODO options
    end
    return @context_warnings[context.id]
  end
  
  def context_valid?(context = MetaContext.core)
    context_warnings(context).empty?
  end
  
end
