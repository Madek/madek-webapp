class Dilps2::Group < Dilps2::Base
  set_table_name 'd2_group'

# TODO
#  belongs_to :parent
  has_many :children, :class_name => "Dilps2::Group",
                      :foreign_key => "parent"

  has_many :group_resources, :class_name => "Dilps2::GroupResource",
                             :foreign_key => "groupid",
                             :conditions => {:collectionid => '#{collectionid}'}


  named_scope :roots, :conditions => {:parent => 0}


#temp#  has_many :items, :through => :group_resources
  def items
    group_resources.collect(&:item).compact    
  end

end
