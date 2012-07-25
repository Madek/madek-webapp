class MediaResourceArc < ActiveRecord::Base

  validate :no_self_reference, :only_set_as_parent, :only_media_entry_as_cover
  validates_uniqueness_of :child_id, :scope => :parent_id
  validates_uniqueness_of :cover, :scope => :parent_id, :if => Proc.new {|x| x.cover }

  belongs_to  :child, :class_name => "MediaResource",  :foreign_key => :child_id
  belongs_to  :parent, :class_name => "MediaResource",  :foreign_key => :parent_id

  private 

  def no_self_reference
    if child.id == parent.id
      errors[:base] << "parent and child must not be equal"
    end
  end

  def only_set_as_parent
    if parent.class != MediaSet
      errors[:base] << "only sets can be parents"
    end
  end

  def only_media_entry_as_cover
    if cover and child.class != MediaEntry
      errors[:base] << "only media_entries can be covers"
    end
  end

end

