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
  validates_presence_of :meta_key, :value #old# :resource_type, :resource_id 
  
  attr_accessor :keep_original_value

  before_save do
    case meta_key.object_type
      when nil, "Meta::Country"
      #working here# TODO set String for 'subject' key
      #when "String"
      #  self.value = value.split(',')
      else
        klass = meta_key.object_type.constantize
        values = case klass.name # NOTE comparing directly the class doesn't work
                    when "Person"
                      klass.split(Array(value))
                    when "Meta::Date"
                      value.to_s.split(' - ') # Needs to be a string because other objects might not have .split, which breaks
                                              # parsing the date. Mostly a safety measure, but also to make migration from 0.1.2 to 0.1.3 work.
                    else
                      Array(value)
                 end
        # TODO Person.suspend_delta
        self.value = values.map do |v|
                          if klass == Keyword
                            user = resource.editors.latest || (resource.respond_to?(:user) ? resource.user : nil)
                            if user.nil? and resource.is_a?(Snapshot)
                              # the Snapshot has just been created, so we take exactly the MediaEntry's keyword
                              r = klass.find(v)
                            else
                              if v.is_a?(Fixnum) or (v.respond_to?(:match) and !!v.match(/\A[+-]?\d+\Z/)) # TODO patch to String#is_numeric? method
                                r = klass.where(:meta_term_id => v, :id => value_was).first
                                r ||= klass.create(:meta_term_id => v, :user => user)
                              else
                                # 2210
                                #conditions = [[]]
                                #LANGUAGES.each do |lang|
                                #  conditions.first << "#{lang} = ?"
                                #  conditions << v
                                #end
                                #conditions[0] = conditions.first.join(" OR ")
                                conditions = {DEFAULT_LANGUAGE => v} 
                                term = Meta::Term.where(conditions).first
                                
                                term ||= begin
                                  h = {}
                                  LANGUAGES.each do |lang|
                                    h[lang] = v
                                  end
                                  Meta::Term.create(h) 
                                end
  
                                r = Keyword.where(:meta_term_id => term, :user_id => user).first
                                r ||= Keyword.create(:meta_term => term, :user => user)
                                # TODO delete keywords records anymore referenced by any meta_data (it could be the same keyword is referenced to a Snapshot)
                              end
                            end
                          elsif klass == Meta::Term
                            #2603# TODO dry
                            if v.is_a?(Fixnum) or (v.respond_to?(:match) and !!v.match(/\A[+-]?\d+\Z/)) # TODO patch to String#is_numeric? method
                              # TODO check if is member of meta_key.meta_terms
                              r = klass.where(:id => v).first
                            elsif meta_key.is_extensible_list?
                              h = {}
                              LANGUAGES.each do |lang|
                                h[lang] = v
                              end
                              term = Meta::Term.find_or_create_by_en_GB_and_de_CH(h)
                              meta_key.meta_terms << term unless meta_key.meta_terms.include?(term)
                              r = term
                            end
                          elsif v.is_a?(Fixnum) or (v.respond_to?(:match) and !!v.match(/\A[+-]?\d+\Z/)) # TODO patch to String#is_numeric? method
                            r = klass.where(:id => v).first
                          elsif klass == Copyright
                            r = value  
                          elsif klass == Person
                            firstname, lastname = klass.parse(v)
                            r = klass.find_or_create_by_firstname_and_lastname(:firstname => firstname.try(:capitalize), :lastname => lastname.try(:capitalize)) if firstname or lastname
                          elsif klass == Meta::Date
                            r = klass.parse(v)
                          end
                          
                          (r ? r.id : nil )
                      end
        value.uniq.compact!
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
      case meta_key.object_type
        when "Meta::Date"
          v.join(' - ')
        else
          v.join(', ')
      end
    else
      v.to_s
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
          v = Array(read_attribute(:value)) # OPTIMIZE 0,1,n limits, return single value if it isn't an Array
          return klass.where(:id => v).to_a
      end
    end
  end

##########################################################

  def same_value?(other_value)
    case value
      when String
        value == other_value
      when Array
        return false unless other_value.is_a?(Array)
        if value.first.is_a?(Meta::Date) 
          other_value.first.is_a?(Meta::Date) && (other_value.first.free_text == value.first.free_text)
        elsif meta_key.object_type == "Keyword"
          referenced_meta_term_ids = Keyword.where(:id => other_value).all.map(&:meta_term_id)
          deserialized_value.map(&:meta_term_id).uniq.sort.eql?(referenced_meta_term_ids.uniq.sort)
        else
          value.uniq.sort.eql?(other_value.uniq.sort)
        end
      when NilClass
        other_value.blank?
    end
  end
  
  
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
