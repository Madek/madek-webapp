# -*- encoding : utf-8 -*-
class MetaTerm < ActiveRecord::Base
  has_many :meta_key_meta_terms, :foreign_key => :meta_term_id
  has_many :meta_keys, :through => :meta_key_meta_terms

  # TODO include keywords ??
  has_and_belongs_to_many :meta_data
  #tmp# has_many :keywords, :foreign_key => :meta_term_id

  validate do
    errors.add(:base, "A term cannot be blank") if LANGUAGES.all? {|lang| send(lang).blank? }
  end

  def to_s(lang = nil)
    lang ||= DEFAULT_LANGUAGE
    self.send(lang)
  end

  ######################################################

    def reassign_meta_data_to_term(term, meta_key = nil)
      meta_data_to_reassign = meta_key ? meta_data.where(:meta_key_id => meta_key) : meta_data
      meta_data_to_reassign.each do |md|
        md.value = md.value.map {|x| x == self ? term : x }
        md.save
      end
    end
  
  ######################################################

    def is_used?
      self.class.used_ids.include?(self.id)
    end
  
    # OPTIMIZE method cache
    def self.used_ids
      @used_ids ||= begin
        ids = MetaContext.all.map {|x| [x.label_id, x.description_id] }
        ids += MetaKeyDefinition.all.map {|x| [x.label_id, x.description_id, x.hint_id] }
        ids += MetaKey.for_meta_terms.collect(&:used_term_ids)
        ids += Keyword.select(:meta_term_id).group(:meta_term_id).collect(&:meta_term_id)
        ids.flatten.uniq.compact
      end
    end
  
  ######################################################

  # OPTIMIZE 2210 uniqueness
  def self.find_or_create(h)
    if h.is_a? MetaTerm
      h
    elsif h.is_a? Integer
      find_by_id(h)
    elsif h.values.any? {|x| not x.blank? }
      find_or_create_by_en_gb_and_de_ch(h)
    end
  end

end
