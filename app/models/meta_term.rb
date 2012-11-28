# -*- encoding : utf-8 -*-
class MetaTerm < ActiveRecord::Base
  has_many :meta_key_meta_terms, :foreign_key => :meta_term_id
  has_many :meta_keys, :through => :meta_key_meta_terms

  # TODO include keywords ??
  has_and_belongs_to_many :meta_data
  has_many :keywords, :foreign_key => :meta_term_id

  validate do
    errors.add(:base, "A term cannot be blank") if LANGUAGES.all? {|lang| send(lang).blank? }
  end

  scope :with_meta_data, where(%Q<
    "meta_terms"."id" in (#{joins(:meta_data).select('"meta_terms"."id"').group('"meta_terms"."id"').to_sql}) >)
    # essentially does the same as above with DISTINCT ON instead of GROUP BY, 
    # queries are different but there is no much difference in speed
  scope :with_keywords, where(%Q<
    "meta_terms"."id" in (#{joins(:keywords).select('DISTINCT ON ("meta_terms"."id") "meta_terms"."id"').to_sql}) >)


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
      MetaKeyDefinition.where("? IN (label_id, description_id, hint_id)", id).exists? or
      MetaContext.where("? IN (label_id, description_id)", id).exists? or
      meta_key_meta_terms.exists? or
      keywords.exists? or
      meta_data.exists?
    end
  
  ######################################################

  # OPTIMIZE 2210 uniqueness
  def self.find_or_create(h)
    if h.is_a? MetaTerm
      h
    elsif h.is_a? Integer
      find_by_id(h)
    elsif h.is_a? String
      l = {}
      LANGUAGES.each do |lang|
        l[lang] = h
      end
      find_or_create_by_en_gb_and_de_ch(l)
    elsif h.values.any? {|x| not x.blank? }
      find_or_create_by_en_gb_and_de_ch(h)
    end
  end

end
