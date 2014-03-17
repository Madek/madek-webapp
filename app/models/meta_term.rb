# -*- encoding : utf-8 -*-
class MetaTerm < ActiveRecord::Base
  has_many :meta_key_meta_terms, :foreign_key => :meta_term_id
  has_many :meta_keys, :through => :meta_key_meta_terms

  # TODO include keywords ??
  has_and_belongs_to_many :meta_data,
    join_table: :meta_data_meta_terms, 
    foreign_key: :meta_term_id, 
    association_foreign_key: :meta_datum_id
  has_many :keywords, :foreign_key => :meta_term_id

  validate do
    errors.add(:base, "A term cannot be blank") if LANGUAGES.all? {|lang| send(lang).blank? }
  end

  after_save :update_searchable
  after_save :update_trgm_searchable

  scope :with_meta_data, lambda{where(%Q<
    "meta_terms"."id" in (#{joins(:meta_data).select('"meta_terms"."id"').group('"meta_terms"."id"').to_sql}) >)}
    # essentially does the same as above with DISTINCT ON instead of GROUP BY, 
    # queries are different but there is no much difference in speed
  scope :with_keywords, lambda{where(%Q<
    "meta_terms"."id" in (#{joins(:keywords).select('DISTINCT ON ("meta_terms"."id") "meta_terms"."id"').to_sql}) >)}

  scope :with_key_labels, lambda{where(%Q<
    "meta_terms"."id" IN (SELECT "label_id" FROM "meta_key_definitions" GROUP BY "label_id") >)}

  scope :with_key_hints, lambda{where(%Q<
    "meta_terms"."id" IN (SELECT "hint_id" FROM "meta_key_definitions" GROUP BY "hint_id") >)}

  scope :with_key_descriptions, lambda{where(%Q<
    "meta_terms"."id" IN (SELECT "description_id" FROM "meta_key_definitions" GROUP BY "description_id") >)}

  scope :used, ->(are_used = true){
    condition = are_used ? 'EXISTS' : 'NOT EXISTS'
    operator  = are_used ? 'OR'     : 'AND'
    where(%Q<
      #{condition} (SELECT NULL FROM "meta_key_definitions" WHERE "meta_terms"."id" = "meta_key_definitions"."label_id") #{operator}
      #{condition} (SELECT NULL FROM "meta_key_definitions" WHERE "meta_terms"."id" = "meta_key_definitions"."hint_id") #{operator}
      #{condition} (SELECT NULL FROM "meta_key_definitions" WHERE "meta_terms"."id" = "meta_key_definitions"."description_id") #{operator}
      #{condition} (SELECT NULL FROM "meta_data_meta_terms" WHERE "meta_terms"."id" = "meta_data_meta_terms"."meta_term_id") #{operator}
      #{condition} (SELECT NULL FROM "keywords" WHERE "meta_terms"."id" = "keywords"."meta_term_id") #{operator}
      #{condition} (SELECT NULL FROM "meta_contexts" WHERE "meta_terms"."id" = "meta_contexts"."label_id") #{operator}
      #{condition} (SELECT NULL FROM "meta_contexts" WHERE "meta_terms"."id" = "meta_contexts"."description_id") #{operator}
      #{condition} (SELECT NULL FROM "meta_keys_meta_terms" WHERE "meta_terms"."id" = "meta_keys_meta_terms"."meta_term_id") >)
  }

  scope :not_used, lambda{where(%Q<
    NOT EXISTS (SELECT NULL FROM "meta_key_definitions" WHERE "meta_terms"."id" = "meta_key_definitions"."label_id") AND
    NOT EXISTS (SELECT NULL FROM "meta_key_definitions" WHERE "meta_terms"."id" = "meta_key_definitions"."hint_id") AND
    NOT EXISTS (SELECT NULL FROM "meta_key_definitions" WHERE "meta_terms"."id" = "meta_key_definitions"."description_id") AND
    NOT EXISTS (SELECT NULL FROM "meta_data_meta_terms" WHERE "meta_terms"."id" = "meta_data_meta_terms"."meta_term_id") AND
    NOT EXISTS (SELECT NULL FROM "keywords" WHERE "meta_terms"."id" = "keywords"."meta_term_id") AND
    NOT EXISTS (SELECT NULL FROM "meta_contexts" WHERE "meta_terms"."id" = "meta_contexts"."label_id") AND
    NOT EXISTS (SELECT NULL FROM "meta_contexts" WHERE "meta_terms"."id" = "meta_contexts"."description_id") AND
    NOT EXISTS (SELECT NULL FROM "meta_keys_meta_terms" WHERE "meta_terms"."id" = "meta_keys_meta_terms"."meta_term_id") >)}

  def to_s(lang = nil)
    lang ||= DEFAULT_LANGUAGE
    self.send(lang)
  end

  USAGE = [:key_label, :key_hint, :key_description]

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

    def used_times
      MetaKeyDefinition.where("? IN (label_id, description_id, hint_id)", id).count +
      MetaContext.where("? IN (label_id, description_id)", id).count +
      meta_key_meta_terms.count +
      keywords.count +
      meta_data.count
    end

  ######################################################

    def used_as?(type)
      case type
      when :term
        meta_data.exists?
      when :keyword
        keywords.exists?
      when :key_label
        MetaKeyDefinition.where(label_id: id).exists?
      when :key_hint
        MetaKeyDefinition.where(hint_id: id).exists?
      when :key_description
        MetaKeyDefinition.where(description_id: id).exists?
      else
        false
      end
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
      find_or_create_by h
    end
  end

  ### text search ######################################## 
  # postgres' text doesn't split up de_ch addresses; let's do it manually in a searchable field;
  # since we have searchable field, let's put all strings in there; searching is simpler and we need only one index 
  
  def convert_to_searchable str
    str = str.to_s
    [str,str.gsub(/[^\w]/,' ').split(/\s+/)].flatten.sort.join(' ')
  end

  def update_searchable
    update_columns searchable: [convert_to_searchable(en_gb || ''),convert_to_searchable(de_ch || '')].flatten.compact.sort.uniq.join(" ")
  end

  def update_trgm_searchable
    update_columns trgm_searchable: [en_gb,de_ch].flatten.compact.sort.uniq.join(" ")
  end

  scope :text_search, lambda{|search_term| where(searchable: search_term)}

  scope :text_rank_search, lambda{|search_term| 
    rank= text_search_rank :searchable, search_term
    select("#{'meta_terms.*,' if select_values.empty?}  #{rank} AS search_rank") \
      .where("#{rank} > 0.05") \
      .reorder("search_rank DESC") }

  scope :trgm_rank_search, lambda{|search_term| 
    rank= trgm_search_rank :trgm_searchable, search_term
    select("#{'meta_terms.*,' if select_values.empty?} #{rank} AS search_rank") \
      .where("#{rank} > 0.05") \
      .reorder("search_rank DESC") }

end
