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
  
end
