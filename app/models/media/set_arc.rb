class Media::SetArc < ActiveRecord::Base
  validate :no_self_reference

  belongs_to  :child, :class_name => "Media::Set",  :foreign_key => :child_id
  belongs_to  :parent, :class_name => "Media::Set",  :foreign_key => :parent_id

  private 

  def no_self_reference
    if child.id == parent.id
      error "parent and child must not be equal"
    end
  end

end

