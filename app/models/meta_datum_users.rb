# -*- encoding : utf-8 -*-
 
class MetaDatumUsers < MetaDatum
  has_and_belongs_to_many :users, 
    join_table: :meta_data_users, 
    foreign_key: :meta_datum_id, 
    association_foreign_key: :user_id

  alias_attribute :value, :users

  def to_s
    Array(deserialized_value).map(&:to_s).join("; ")
  end

end


