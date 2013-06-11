class Dilps::SuperItem < Dilps::Base
  self.table_name = 'super_items'
  self.primary_keys = :collection_id, :item_id

  has_many :connections, class_name: '::Dilps::Connection', \
    primary_key: [:collection_id, :item_id], foreign_key: [:collection_id,:item_id] 

  has_many :nested_groups, through: :connections

  has_many :keyword_groups, class_name: 'NestedGroup', source: :nested_group,  \
    through: :connections, conditions: ['nested_groups.l1_name = "index"']

  has_many :user_groups, class_name: 'NestedGroup', source: :nested_group, \
    through: :connections, conditions: ['nested_groups.l1_name = "user"']

  has_one :resource_rev, foreign_key: :resource_id, primary_key: :resource_id

  belongs_to :collection

  def self.by_user user_name
    select("DISTINCT `super_items`.*").joins(:user_groups) \
      .where("nested_groups.l2_name in (?)", user_name)
  end


  def extended_data 
    ::Dilps::ExtendedDatum \
      .joins("INNER JOIN d2_item_ext_rev ON extended_data.id = d2_item_ext_rev.item_ext_data_id") \
      .where("d2_item_ext_rev.item_revid = ?", item_rev_id)
  end

  def resource_path
    "." + collection.storage_dir + File::SEPARATOR + "master" + File::SEPARATOR + (resource_rev.try(:filename) || "unknown")
  end

end
