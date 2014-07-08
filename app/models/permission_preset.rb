class PermissionPreset < ActiveRecord::Base
  validates_presence_of :name
  
  before_create :set_position
  after_destroy 'self.class.regenerate_positions'

  default_scope { order('position') }

  def set_position
    if PermissionPreset.last.present?
      self.position = PermissionPreset.last.position + 1
    else
      self.position = 1
    end
  end

  def move_higher
    if (higher = PermissionPreset.find_by position: self.position - 1).present?
      PermissionPreset.transaction do
        higher.update_attributes(position: self.position)
        self.update_attributes(position: self.position - 1)
      end
    end
  end

  def move_lower
    if (lower = PermissionPreset.find_by position: self.position + 1).present?
      PermissionPreset.transaction do
        lower.update_attributes(position: self.position)
        self.update_attributes(position: self.position + 1)
      end
    end
  end

  def self.regenerate_positions
    transaction do
      all.each_with_index do |pp, i|
        pp.update_attribute(:position, i+1)
      end
    end
  end
end
