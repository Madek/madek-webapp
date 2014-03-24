# -*- encoding : utf-8 -*-
#= MediaEntryIncomplete
#
# This class is a subclass of MediaEntry, referring to the uploading media_entries.

class MediaEntryIncomplete < MediaEntry

  include MediaResourceModules::MetaDataExtraction
  include MediaResourceModules::Importer


  def set_as_complete
    me = becomes MediaEntry
    update_column(:type, MediaEntry.to_s)
    me
  end

end
