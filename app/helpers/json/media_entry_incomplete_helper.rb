module Json
  module MediaEntryIncompleteHelper

    def hash_for_media_entry_incomplete(media_entry_incomplete, with = nil)
      {
        id: media_entry_incomplete.id,
        filename: media_entry_incomplete.media_file.filename,  
        size: media_entry_incomplete.media_file.size
      }
    end
  end
end
      