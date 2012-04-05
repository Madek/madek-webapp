# -*- encoding : utf-8 -*-
class Keyword < ActiveRecord::Base
  
  belongs_to :meta_term, :class_name => "MetaTerm"
  belongs_to :user # TODO person ??
  #belongs_to :media_entry

  validates_presence_of :meta_term

  default_scope :include => :meta_term

  def to_s
    "#{meta_term}"
  end
  
  #tmp# wrong! TODO through new method meta_data
#  def resources
#    a = []
#    MetaKey.where(:object_type => "Keyword").each do |key|
#      key.meta_data.each do |md|
#        a += [md.resource_type, md.resource_id] if md.value.include?(id)
#      end
#    end
#    a
#  end

  def meta_data
    MetaDatum.joins(:meta_key).
      where(:meta_keys => {:object_type => self.class.name}).
      where(["value REGEXP ?", "-\ #{id}\n" ])
  end

#######################################

  def self.search(query)
    return scoped unless query

    sql = select("DISTINCT keywords.*").joins(:meta_term)

    w = query.split.map do |x|
      "(%s)" % LANGUAGES.map do |l|
        if SQLHelper.adapter_is_mysql?
          "meta_terms.#{l} LIKE '%#{x}%'"
        elsif SQLHelper.adapter_is_postgresql?
          "meta_terms.#{l} ILIKE '%#{x}%'"
        else
          raise "this db adapter is not supported"
        end
      end.join(' OR ')
    end.join(' AND ')
    sql.where(w)
  end
  
end
