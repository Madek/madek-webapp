class Dilps2::GroupResource < Dilps2::Base
  set_table_name 'd2_group_resource'

  has_one :item, :class_name => "Dilps2::Item",
                 :foreign_key => "imageid",
                 :primary_key => "itemid",
                 :conditions => {:collectionid => '#{item_collection}'}

  # TODO ??
  # has_one :group

end
