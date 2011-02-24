# -*- encoding : utf-8 -*-
module Meta
  def self.table_name_prefix
    "meta_"
  end

  class Term < ActiveRecord::Base
    has_and_belongs_to_many :meta_keys, :join_table => :meta_keys_meta_terms,
                                        :foreign_key => :meta_term_id
  
    validate :validations
    
    def to_s(lang = nil)
      lang ||= DEFAULT_LANGUAGE
      self.send(lang)
    end
  
  ######################################################
  
    def meta_data
      meta_keys.collect(&:meta_data).flatten.select {|x| x.value.include?(self.id) }
    end
  
    def reassign_meta_data_to_term(term)
      meta_data.each do |md|
        md.value.map! do |x|
          if x == self.id
            term.id
          else
            x
          end
        end
        md.save
      end
    end
  
  ######################################################
  
    def is_used?
      self.class.used_ids.include?(self.id)
    end
  
    # TODO method cache
    def self.used_ids
      @used_ids ||= begin
        ids = (MetaContext.all + MetaKeyDefinition.all).collect do |x|
          # TODO fetch id directly
          [x.meta_field.label.try(:id), x.meta_field.description.try(:id), x.meta_field.hint.try(:id)]
        end
        ids += MetaKey.where(:object_type => "Meta::Term").collect(&:meta_data).flatten.collect do |x|
          x.value
        end
        ids.flatten.uniq.compact
      end
    end
  
  ######################################################
  
    private
  
    def validations
      errors.add_to_base("A term cannot be blank") if LANGUAGES.all? {|lang| send(lang).blank? }
    end
  
  end

end