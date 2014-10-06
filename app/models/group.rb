# -*- encoding : utf-8 -*-
class Group < ActiveRecord::Base

  has_many :grouppermissions
  has_and_belongs_to_many :users

  after_save :update_searchable

  validates_presence_of :name
  validates :name, uniqueness: { scope: :institutional_group_name }

  scope :departments, ->{where(:type => "InstitutionalGroup")}

  def to_s
    name
  end

  def is_readonly?
    ["Admin", "ZHdK (Zürcher Hochschule der Künste)"].include?(name) # FIXME remove zhdk
  end

### use in case counters get broken ####################

  def self.reset_users_count
    Group.all.each do |group|
      group.update_attributes(users_count: group.users.count)
    end
  end

### text search ######################################## 
  
  def update_searchable
    update_columns searchable: [name,institutional_group_name,].flatten \
      .compact.sort.uniq.join(" ")
  end

  scope :text_search, lambda{|search_term| where("searchable ILIKE :term", term: "%#{search_term}%")}

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
