class Collection

  def self.add ids, collection_id = nil
    if collection_id.nil? or not Rails.cache.exist? collection_id
      collection_id = UUIDTools::UUID.timestamp_create.to_s
    else
      ids = ids|Rails.cache.read(collection_id) if Rails.cache.read(collection_id).is_a? Array
    end
    Rails.cache.write collection_id, ids, :expires_in => 1.week
    {:id => collection_id, :count => ids.count, :ids => ids}
  end

  def self.remove ids, collection_id = nil
    if Rails.cache.exist? collection_id
      ids = Array(Rails.cache.read(collection_id)) - Array(ids)
      Rails.cache.write collection_id, ids, :expires_in => 1.week
    else
      collection_id = UUIDTools::UUID.timestamp_create.to_s
    end
    {:id => collection_id, :count => ids.count, :ids => ids}
  end

  def self.destroy collection_id = nil
    if Rails.cache.exist? collection_id
      Rails.cache.delete collection_id
    end
  end

  def self.get collection_id
    if Rails.cache.exist? collection_id
      collection = Rails.cache.read(collection_id)
      {:id => collection_id, :count => collection.count, :ids => collection}
    else
      raise "collection_id does not exist"
    end
  end

  def self.exist? collection_id
    Rails.cache.exist? collection_id
  end

end