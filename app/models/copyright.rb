# -*- encoding : utf-8 -*-
class Copyright < ActiveRecord::Base

  default_scope { reorder(:label) }

  has_many :meta_datum_copyrights

  validates_presence_of :label

  scope :roots, ->{where("parent_id is NULL")}

  belongs_to :parent, class_name: "Copyright"

  def root
    unless parent_id
      self
    else
      parent.root
    end
  end


  def children
    Copyright.where("parent_id = ?",id)
  end

  def leaf?
    children.count == 0
  end

  def to_s
    label
  end

  def is_deletable?
    not has_descendants? and meta_datum_copyrights.empty?
  end

  def has_descendants? 
    Copyright.where("parent_id = ?",id).count > 0
  end


#######################################

  def usage(value = "")
    (is_custom? ? value : read_attribute(:usage))
  end

  def url(value = "")
    (is_custom? ? value : read_attribute(:url))
  end
  
#######################################
  
  def self.default
    @default ||= where(:is_default => true).first
  end

  def self.custom
    @custom ||= where(:is_custom => true).first
  end

  def self.public
    where(:label => "Public Domain / Gemeinfrei").first
  end

##################################################

end
