# -*- encoding : utf-8 -*-
#= MetaDatum
# The Association class for relating a Resource (e.g. a MediaEntry) to a MetaKey and a value for that key.
#
# Values are serialized objects (but should we be using composed_of instead?)
class MetaDatum < ActiveRecord::Base


  class << self

    alias_method :new_orig, :new

    def new *args
      if args[0] and args[0][:meta_key_id] and meta_key_id = args[0][:meta_key_id].to_i
        if meta_key_id == 8
          MetaDatumDate.new_orig *args
        else
          self.new_orig *args
        end
      else
        self.new_orig *args
      end
    end

  end



  belongs_to :media_resource
  belongs_to :meta_key

  serialize :value

  validates_uniqueness_of :meta_key_id, :scope => :media_resource_id
  validates_presence_of :meta_key
  
  attr_accessor :keep_original_value

  scope :for_meta_terms, joins(:meta_key).where(:meta_keys => {:object_type => "MetaTerm"})

=begin #Thomas#
  class << self
    def new_with_cast(*a, &b)
      if (h = a.first).is_a? Hash and (type = h[:type] || h['type']) and (klass = type.constantize) != self
        raise "wtF hax!!"  unless klass < self  # klass should be a descendant of us
        return klass.new(*a, &b)
      end

      new_without_cast(*a, &b)
    end
    alias_method_chain :new, :cast
  end
=end

  before_save :set_value_before_save

  after_save do
    reload
    if type == "MetaDatumString"
      SQLHelper.execute_sql "UPDATE meta_data SET value = NULL where id = #{id}"
    end
  end
 
  def set_value_before_save
    case meta_key.object_type
      when nil, "MetaCountry"
        self.type = "MetaDatumString"
        self.string = self.value
        self.value = nil
      when "MetaDate"
        binding.pry
      else
        klass = meta_key.object_class
        values = case klass.name # NOTE comparing directly the class doesn't work
                    when "Person"
                      klass.split(Array(value))
                    when "MetaDate"
                      value.to_s.split(' - ') # Needs to be a string because other objects might not have .split, which breaks
                                              # parsing the date. Mostly a safety measure, but also to make migration from 0.1.2 to 0.1.3 work.
                    else
                      Array(value)
                 end
        self.value = values.map do |v|
                          if klass == Keyword
                            user = media_resource.editors.latest || (media_resource.respond_to?(:user) ? media_resource.user : nil)
                            if user.nil? and media_resource.is_a?(Snapshot)
                              # the Snapshot has just been created, so we take exactly the MediaEntry's keyword
                              r = klass.find(v)
                            else
                              if v.is_a?(Fixnum) or (v.respond_to?(:is_integer?) and v.is_integer?)
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
                                term = MetaTerm.where(conditions).first

                                term ||= begin
                                  h = {}
                                  LANGUAGES.each do |lang|
                                    h[lang] = v
                                  end
                                  MetaTerm.create(h)
                                end
                                
                                # TODO FRANCO FIXME CAN WE SHARE KEYWORDS BETWEEN MEDIA RESOURCES .... WHATS WITH COUNTING ??
                                r = Keyword.where(:meta_term_id => term, :user_id => user).first
                                r ||= Keyword.create(:meta_term => term, :user => user)
                                # TODO delete keywords records anymore referenced by any meta_data (it could be the same keyword is referenced to a Snapshot)
                              end
                            end
                          elsif klass == MetaTerm
                            #2603# TODO dry
                            if v.is_a?(Fixnum) or (v.respond_to?(:is_integer?) and v.is_integer?)
                              # TODO check if is member of meta_key.meta_terms
                              r = klass.where(:id => v).first
                            elsif meta_key.is_extensible_list?
                              h = {}
                              LANGUAGES.each do |lang|
                                h[lang] = v
                              end
                              term = MetaTerm.find_or_create_by_en_gb_and_de_ch(h)
                              meta_key.meta_terms << term unless meta_key.meta_terms.include?(term)
                              r = term
                            end
                          elsif v.is_a?(Fixnum) or (v.respond_to?(:is_integer?) and v.is_integer?)
                            r = klass.where(:id => v).first
                          elsif klass == Copyright
                            r = value
                          elsif klass == User
                            r = value
                          elsif klass == Person
                            firstname, lastname = klass.parse(v)
                            r = klass.find_or_create_by_firstname_and_lastname(:firstname => firstname, :lastname => lastname) if firstname or lastname
                          elsif klass == MetaDate
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
    s = if v.is_a?(Array)
      case meta_key.object_type
        when "MetaDate"
          v.join(' - ')
        else
          v.join(', ')
      end
    else
      v.to_s
    end
    # We must force the encoding of the retrieved string, otherwise it gives us the form it deserialized
    # into ASCII-8BIT, which looks like this: "\xE2\x88\x86G  = \xE2\x88\x86G\xC2\xB0\xE2\x80\x99 +  R T lnK"
    # Those multibyte characters are useless to us in that form and the encoding mismatch triggers an
    # EncodingError exception.
    s.force_encoding("utf-8")
  end

  # some meta_keys don't store values,
  # then the returned value could be a stored one or dynamically computed
  #working here# TODO deserialized_value #value
  def deserialized_value
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
    else
      case meta_key.object_type
        when nil, "MetaCountry"
          return read_attribute(:value)
        else
          klass = meta_key.object_class
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
        if value.first.is_a?(MetaDate)
          other_value.first.is_a?(MetaDate) && (other_value.first.free_text == value.first.free_text)
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
    r = []

    definition = meta_key.meta_key_definitions.for_context(context)

    r << "can't be blank" if value.blank? and definition.is_required
    r << "is too short (min is #{definition.length_min} characters)" if definition.length_min and (value.blank? or value.size < definition.length_min)
    r << "is too long (maximum is #{definition.length_max} characters)" if value and definition.length_max and value.size > definition.length_max
    # TODO options
    
    r
  end

  def context_valid?(context = MetaContext.core)
    context_warnings(context).empty?
  end

end
