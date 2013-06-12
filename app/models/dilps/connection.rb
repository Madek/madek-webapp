class Dilps::Connection < Dilps::Base
  self.table_name = 'connections'
  self.inheritance_column = :nil
  self.primary_keys= :item_collection_id, :item_id, :resource_id, :group_id

  has_one :nested_group, foreign_key: :l3_id, primary_key: :group_id
end
