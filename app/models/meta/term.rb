# -*- encoding : utf-8 -*-
module Meta
  def self.table_name_prefix
    "meta_"
  end

  class Term < ActiveRecord::Base
    has_and_belongs_to_many :meta_keys, :join_table => :meta_keys_meta_terms,
                                        :foreign_key => :meta_term_id

    #tmp# has_many :keywords, :foreign_key => :meta_term_id
    
    validate :validations
    
    def to_s(lang = nil)
      lang ||= DEFAULT_LANGUAGE
      self.send(lang)
    end
  
  ######################################################

    # TODO refactor to has_many through association ??
    # TODO include keywords ??
    def meta_data(meta_key = nil)
      meta_keys.collect(&:meta_data).flatten.select {|x| x.value.include?(self.id) and (meta_key.nil? or x.meta_key == meta_key) }
    end
    
    def reassign_meta_data_to_term(term, meta_key = nil)
      meta_data(meta_key).each do |md|
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
        ids += MetaKey.where(:object_type => "Meta::Term").collect(&:used_term_ids)
        ids += Keyword.select(:meta_term_id).group(:meta_term_id).collect(&:meta_term_id)
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