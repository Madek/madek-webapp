# -*- encoding : utf-8 -*-
#= MediaEntry
#
# This class could just as easily also be known as MediaObject..
# and one day might become so.

class MediaEntry < MediaResource
  
  belongs_to                :media_file #, :include => :previews # TODO validates_presence # TODO on destroy, also destroy the media_file if this is the only related media_entry and snapshot
  belongs_to                :upload_session
  belongs_to                :user # NOTE this redundant with upload_session.user_id
  has_many                  :snapshots

  has_and_belongs_to_many   :media_sets, :join_table => "media_entries_media_sets",
                                         :association_foreign_key => "media_set_id" # TODO validate_uniqueness
  alias :parent_sets :media_sets

########################################################

  # OPTIMIZE
  def individual_contexts
    media_sets.flat_map {|set| set.individual_contexts }.uniq
  end

########################################################

  def to_s
    "#{title}"
  end

  # compares two objects in order to sort them
  # required by dot
  def <=>(other)
    self.updated_at <=> other.updated_at
  end

########################################################

  def as_json(options={})
    options ||= {}
    json = super(options)
    
    # TODO shouldnt be set per default
    json[:is_set] = false
    json[:can_maybe_browse] = meta_data.for_meta_terms.exists?
    
    if(with = options[:with])
      if(with[:media_entry] and with[:media_entry].is_a?(Hash))
        if with[:media_entry].has_key?(:author) and (with[:media_entry][:author].is_a?(Hash) or not with[:media_entry][:author].to_i.zero?)
          author = meta_data.get("author").deserialized_value.first # FIXME get all if many
          json[:author] = {}
          json[:author][:id] = author.id
          if with[:media_entry][:author].has_key?(:name) and (with[:media_entry][:author][:name].is_a?(Hash) or not with[:media_entry][:author][:name].to_i.zero?)
            json[:author][:name] = author.to_s
          end 
        end
        if with[:media_entry].has_key?(:title) and (with[:media_entry][:title].is_a?(Hash) or not with[:media_entry][:title].to_i.zero?)
          json[:title] = meta_data.get_value_for("title")
        end
        if with[:media_entry].has_key?(:image) and (with[:media_entry][:image].is_a?(Hash) or not with[:media_entry][:image].to_i.zero?)
          
          size = if with[:media_entry][:image].is_a?(Hash) and with[:media_entry][:image].has_key?(:size)
              with[:media_entry][:image][:size]
            else
              :small
          end
          
          json[:image] = if with[:media_entry][:image].is_a?(Hash) and with[:media_entry][:image].has_key?(:as)
              case with[:media_entry][:image][:as]
                when "base64"
                  self.media_file.thumb_base64(size)
                else # default return is a url to the image
                  "/resources/%d/image?size=%s" % [id, size]
              end
            else
              "/resources/%d/image?size=%s" % [id, size]
          end            
        end
      end
    end
    
    json
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
        MetaDatum.new(:media_resource => new_blank_media_entry, :meta_key_id => md_bare[:meta_key_id], :value => nil, :keep_original_value => true)
      else
        MetaDatum.new(:media_resource => new_blank_media_entry, :meta_key_id => md_bare[:meta_key_id], :value => md_bare[:value])
      end
      meta_data
   end
 end

end
