class Media::SetArc < ActiveRecord::Base
  belongs_to  :child, :class_name => "Media::Set",  :foreign_key => :child_id
  belongs_to  :parent, :class_name => "Media::Set",  :foreign_key => :parent_id
end

