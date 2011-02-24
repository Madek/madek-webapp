class Dilps2::ResourceRev < Dilps2::Base
  set_table_name 'd2_resource_rev'

  has_one :urn_file, :class_name => "Dilps2::Urn",
                     :primary_key => "urn",
                     :foreign_key => "urn",
                     :conditions => {:protocol => 'file'}
end
