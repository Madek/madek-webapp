# -*- encoding : utf-8 -*-
 
class MetaDatumUsers < MetaDatumBase
  has_and_belongs_to_many :users, 
    join_table: :meta_data_users, 
    foreign_key: :meta_datum_id, 
    association_foreign_key: :user_id

  alias_attribute :value, :users
  alias_attribute :deserialized_value, :users

  def to_s
    value.map(&:to_s).join("; ")
  end

end


