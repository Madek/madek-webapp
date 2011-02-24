class Dilps2::ItemRev < Dilps2::Base
  set_table_name 'd2_item_rev'

  has_and_belongs_to_many :item_ext_data, :class_name => "Dilps2::ItemExtData",
                                          :join_table => "d2_item_ext_rev",
                                          :foreign_key => "item_revid"

end
