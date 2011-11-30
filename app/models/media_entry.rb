# -*- encoding : utf-8 -*-
#= MediaEntry
#
# This class could just as easily also be known as MediaObject..
# and one day might become so.

class MediaEntry < ActiveRecord::Base

  include Resource
  
  belongs_to                :media_file #, :include => :previews # TODO validates_presence # TODO on destroy, also destroy the media_file if this is the only related media_entry and snapshot
  belongs_to                :upload_session
  has_and_belongs_to_many   :media_sets, :class_name => "Media::Set",
                                         :join_table => "media_entries_media_sets",
                                         :association_foreign_key => "media_set_id" # TODO validate_uniqueness
  has_many                  :snapshots

  before_create :extract_subjective_metadata, :set_copyright

  after_create :set_descr_author_value

  def set_descr_author_value
    descr_author_value = record.meta_data.get("description author").value
    record.meta_data.get("description author before import").update_attributes(:value => descr_author_value) if descr_author_value
  end

    # TODO remove and go through permissions ??
  delegate :user, :user_id, :to => :upload_session

  default_scope order("media_entries.updated_at DESC") #-# .includes(:media_file)

########################################################

  # OPTIMIZE
  def individual_contexts
    media_sets.projects.collect {|project| project.individual_contexts }.flatten.uniq
  end

########################################################

  def to_s
    "#{title}"
  end

  # compares two objects in order to sort them
  # required by dot
  def <=>(other)
    self.updated_at <=> other.updated_a_t
  end

########################################################

  def as_json(options={})
    h = { :is_set => false,
          :can_maybe_browse => !meta_data.for_meta_terms.blank?,
          :is_favorite => user.favorite_ids.include?(id) #,
          #:thumb_base64 => media_file.try(:thumb_base64, :small_125)
        }
    super(options).merge(h)
  end

########################################################

  def to_snapshot
    if snapshotable?
      snapshots.first.destroy unless snapshots.empty?
      snapshots.create
    end
  end

  # return true if there is no snapshot already
  # or if there is a just one snapshot that is not edited yet
  def snapshotable?
    snapshots.empty? or (snapshots.count == 1 and not snapshots.first.edited?)
  end
  
########################################################

 def self.compare_batch_by_meta_data_in_context(media_entries, context)
   compared_against, other_entries = media_entries[0], media_entries[1..-1]
   meta_data_for_context = compared_against.meta_data_for_context(context)
   
   new_blank_media_entry = self.new
   meta_data_for_context.inject([]) do |meta_data, md_bare|
      meta_data << if other_entries.any? {|me| not me.meta_data.get(md_bare[:meta_key_id]).same_value?(md_bare[:value])}
        MetaDatum.new(:resource => new_blank_media_entry, :meta_key_id => md_bare[:meta_key_id], :value => nil, :keep_original_value => true)
      else
        MetaDatum.new(:resource => new_blank_media_entry, :meta_key_id => md_bare[:meta_key_id], :value => md_bare[:value])
      end
      meta_data
   end
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
  def extract_subjective_metadata
    return unless ["image", "audio", "video"].any? {|w| self.media_file.content_type.include? w }

     fct = self.media_file.content_type
     group_tags = case fct
                    when /image/ 
                      #NOTE - these two really don't bring much to the party, except broken character encodings.. # 'IPTC:', 'IPTC2']
                      ['XMP-madek', 'XMP-dc', 'XMP-photoshop', 'XMP-iptcCore', 'XMP-xmpRights', 'XMP-expressionmedia', 'XMP-mediapro']
                    when /video/
                      ['QuickTime', 'Track', 'Composite', 'RIFF', 'BMP', 'Flash', 'M2TS', 'AC3', 'H264' ] # OPTIMIZE - some of these may move to Objective Metadata
                    when /audio/ 
                      ['MPEG', 'ID3', 'Track', 'Composite', 'ASF', 'FLAC', 'Vorbis' ] # OPTIMIZE - some of these may move to Objective Metadata
                    when /application/
                      ['FlashPix', 'PDF', 'XMP-', 'PostScript', 'Photoshop', 'EXE', 'ZIP' ] # OPTIMIZE - some of these may move to Objective Metadata
                    when /text/
                      ['HTML' ]  # and inevitably more..
                  end
      ignore_fields = case fct
                        when /image/
                           [/^XMP-photoshop:ICCProfileName$/,/^XMP-photoshop:LegacyIPTCDigest$/, /^XMP-expressionmedia:(?!UserFields)/, /^XMP-mediapro:(?!UserFields)/]
                        when /video/
                          []
                        when /audio/
                          []
                        when /application/
                          []
                        when /text/
                          []
                      end

      blob = exiftool_subjective(self.media_file.file_storage_location, group_tags)
      process_metadata_blob(blob, ignore_fields)
  end


  def process_metadata_blob(blob, ignore_fields = [])
    blob.each do |tag_array_entry|
      tag_array_entry.each do |entry|
        entry_key = entry[0]
        entry_value = entry[1]
        next if ignore_fields.detect {|e| entry_key =~ e}

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
    elsif copyright_status.value.class == TrueClass or are_usage_or_url_defined 
      copyright_status.value = Copyright.custom
    elsif copyright_status.value.class == FalseClass
      copyright_status.value = Copyright.public
    else
      copyright_status.value = Copyright.default
    end
  end


# parses the passed in file reference for the requested tag groups
# returns an array of arrays of meta-data for the group tags requested

#==== Depends on:
# [external] exiftool meta-data manipulation perl library.

  def exiftool_subjective(media, tags = nil)
    result_set = []
    parse_hash = JSON.parse(`#{EXIFTOOL_PATH} -s "#{media}" -a -u -G1 -D -j`).first
    # TODO ?? parse_hash.delete_if {|k,v| v.is_a?(String) and not v.valid_encoding? }
    tags.each do |tag_group|
      result_set << parse_hash.select {|k,v| k.include?(tag_group)}.sort
    end
    result_set
  end

end
