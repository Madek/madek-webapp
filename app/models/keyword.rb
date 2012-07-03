# -*- encoding : utf-8 -*-
class Keyword < ActiveRecord::Base
  
  belongs_to :meta_term
  belongs_to :user
  belongs_to :meta_datum

  validates_presence_of :meta_term # FIXME check after, :meta_datum
  validates_uniqueness_of :meta_term_id, :scope => :meta_datum_id

  default_scope :include => :meta_term

  def to_s
    "#{meta_term}"
  end
  
#######################################

  def self.search(query)
    return scoped unless query

    sql = select("DISTINCT keywords.*").joins(:meta_term)

    w = query.split.map do |x|
      "(%s)" % LANGUAGES.map do |l|
        "meta_terms.#{l} #{SQLHelper.ilike} '%#{x}%'"
      end.join(' OR ')
    end.join(' AND ')

    sql.where(w)
  end
  
end
