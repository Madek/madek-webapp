
class MediaEntriesMediaSets < ActiveRecord::Base 
  set_table_name :media_entries_media_sets
end

class MergeMsmeJointableIntoMra < ActiveRecord::Migration

  def up

    MediaEntriesMediaSets.all.each do |con| 
      MediaSet.find(con.media_set_id).media_entries << MediaResource.find(con.media_entry_id)
    end

    drop_table :media_entries_media_sets

  end

  def down
    raise "this is a irreversibel migration"
  end
end

