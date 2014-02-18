# -*- encoding : utf-8 -*-
class Group < ActiveRecord::Base

  has_many :grouppermissions
  has_and_belongs_to_many :users

  after_save :update_searchable

  validates_presence_of :name

  scope :departments, ->{where(:type => "MetaDepartment")}

  def to_s
    name
  end

  def is_readonly?
    ["Admin", "ZHdK (Zürcher Hochschule der Künste)"].include?(name) # FIXME remove zhdk
  end


### text search ######################################## 
  
  def update_searchable
    update_columns searchable: [name,ldap_name,].flatten \
      .compact.sort.uniq.join(" ")
  end

  scope :text_search, lambda{|search_term| basic_search({searchable: search_term},true)}

  scope :text_rank_search, lambda{|search_term| 
    rank= text_search_rank :searchable, search_term
    select("#{'groups.*,' if select_values.empty?}  #{rank} AS search_rank") \
      .where("#{rank} > 0.05") \
      .reorder("search_rank DESC") }

  scope :trgm_rank_search, lambda{|search_term| 
    rank= trgm_search_rank :searchable, search_term
    select("#{'groups.*,' if select_values.empty?} #{rank} AS search_rank") \
      .where("#{rank} > 0.05") \
      .reorder("search_rank DESC") }


  
end
