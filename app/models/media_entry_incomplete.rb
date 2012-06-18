# -*- encoding : utf-8 -*-
#= MediaEntryIncomplete
#
# This class is a subclass of MediaEntry, referring to the uploading media_entries.

class MediaEntryIncomplete < MediaEntry

  attr_accessor :uploaded_data

  before_create do
    create_media_file(:uploaded_data => uploaded_data)
    extract_and_process_subjective_metadata
    set_copyright
  end

  after_create do
    descr_author_value = meta_data.get("description author", false).try(:value)
    meta_data.get("description author before import").update_attributes(:value => descr_author_value) if descr_author_value
    mdu = meta_data.get("uploaded by")
    mdu.users << user
    mdu.save
  end

########################################################

  def set_as_complete
    becomes MediaEntry
    update_column(:type, type)
    # TODO should we also update the created_at ?? 
  end

########################################################

  private

  # - used by metal/download.rb to collect the key_map tags and their values for writing into the 
  # copy of the original media file that the user is about to download.

  # Handler for extracting some subjective meta-data from whatever file has been handed to us
  #
  #--
  # TODO - more sophisticated importing validations.. some files have a key with a blank entry.. useful! (ie the import will fail if we allow blanks through)
  # TODO - generally everything we get via exiftool will have File and System tags.. do we really want this in subjective MD?
  # TODO - IFD0 tags will contain a camera manufacturer, possibly followed by that manufacturers own data. Parse or not to parse..
  # NOTE - java jar files are zipped, hence the group tag in application
  #++
  def extract_and_process_subjective_metadata
    content_type = self.media_file.content_type
    return unless ["image", "audio", "video"].any? {|w| content_type.include? w }
    meta_arr = Exiftool.extract_madek_subjective_metadata self.media_file.file_storage_location, content_type 
    process_metadata Exiftool.filter_unwanted_fields(meta_arr,content_type)
  end


  def process_metadata meta_arr
    meta_arr.each do |tag_array_entry|
      tag_array_entry.each do |entry|
        entry_key = entry[0]
        entry_value = entry[1]

        if entry_key =~ /^XMP-(expressionmedia|mediapro):UserFields/
          Array(entry_value).each do |s|
            entry_key, entry_value = s.split('=', 2)

            # TODO priority ??
            case entry_key
              when "Datum", "Datierung"
                meta_key = MetaKey.find_by_label("portrayed object dates")
              when "Autor/in"
                meta_key = MetaKey.find_by_label("author")
              else
                next
            end

            # TODO dry
            next if entry_value.blank? or entry_value == "-" or meta_data.detect {|md| md.meta_key == meta_key } # we do sometimes receive a blank value in metadata, hence the check.
            entry_value.gsub!(/\\n/,"\n") if entry_value.is_a?(String) # OPTIMIZE line breaks in text are broken somehow
            meta_data.build(:meta_key => meta_key, :value => entry_value )
          end
        else
          meta_key = MetaKey.meta_key_for(entry_key) #working here#10 , MetaContext.file_embedded)

          next if entry_value.blank? or meta_data.detect {|md| md.meta_key == meta_key } # we do sometimes receive a blank value in metadata, hence the check.
          entry_value.gsub!(/\\n/,"\n") if entry_value.is_a?(String) # OPTIMIZE line breaks in text are broken somehow
          meta_data.build(:meta_key => meta_key, :value => entry_value )
        end

      end
    end
  end
  
#temp#
#  def extract_mediapro_userfields
#  end

  # see mapping table on http://code.zhdk.ch/projects/madek/wiki/Copyright
  def set_copyright
    copyright_status = meta_data.detect {|md| ["copyright status"].include?(md.meta_key.label) }
    are_usage_or_url_defined = meta_data.detect {|md| ["copyright usage", "copyright url"].include?(md.meta_key.label) }

    if !copyright_status
      value = (are_usage_or_url_defined ? Copyright.custom : Copyright.default)
      meta_data.build(:meta_key => MetaKey.find_by_label("copyright status"), :value => value)
    elsif are_usage_or_url_defined 
      copyright_status.value = Copyright.custom
    end
  end


end
