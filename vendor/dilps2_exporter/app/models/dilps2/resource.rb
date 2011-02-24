class Dilps2::Resource < Dilps2::Base
  set_table_name 'd2_resource'

  belongs_to :resource_rev, :class_name => "Dilps2::ResourceRev", :foreign_key => "resource_revid"

#old#  default_scope :conditions => {:main => 1}

end
