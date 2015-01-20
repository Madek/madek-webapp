# -*- encoding : utf-8 -*-
 
class MetaDatumUsers < MetaDatum
  has_and_belongs_to_many :users, 
    join_table: :meta_data_users, 
    foreign_key: :meta_datum_id, 
    association_foreign_key: :user_id

  def to_s
    Array(value).map(&:to_s).join("; ")
  end
  
  def value
    case meta_key.label
      when "owner"
        media_resource.user
      else
        users
    end
  end


  def serializable_hash_with_relations options
    if options[:include] == :meta_key 
      opts= options.deep_dup
      opts[:include] = [:meta_key,{users: {except: [:password_digest]}}]
      serializable_hash_without_relations(opts)
    else
      serializable_hash_without_relations(options)
    end
  end

  alias_method :serializable_hash_without_relations , :serializable_hash
  alias_method :serializable_hash, :serializable_hash_with_relations



end


