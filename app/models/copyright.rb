# -*- encoding : utf-8 -*-
class Copyright < ActiveRecord::Base

  before_create :set_position
  after_destroy :regeerate_position

  default_scope { reorder(:position, :id) }

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

  def parents
    parents = label
    if parent_id.present?
      parents = parent.label
      unless root == parent
        parents = parents + " - " + parent.parents
      end
      parents = parents + " - " + label
    end
    parents
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

  def set_position
    if (last = Copyright.where(parent_id: parent_id).last).present? && last.position.present?
      self.position = last.position + 1
    else
      self.position = 1
    end
  end

  def move_higher
    self.regenerate_positions
    if (higher = Copyright.where(parent_id: parent_id).find_by position: self.position - 1).present?
      Copyright.transaction do
        higher.update_attributes(position: self.position)
        self.update_attributes(position: self.position - 1)
      end
    end
  end

  def move_lower
    self.regenerate_positions
    if (lower = Copyright.where(parent_id: parent_id).find_by position: self.position + 1).present?
      Copyright.transaction do
        lower.update_attributes(position: self.position)
        self.update_attributes(position: self.position + 1)
      end
    end
  end

  def regenerate_positions
    Copyright.transaction do
      Copyright.where(parent_id: parent_id).each_with_index do |pp, i|
        pp.update_attribute(:position, i+1)
      end
    end
  end

end
