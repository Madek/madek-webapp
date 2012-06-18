# -*- encoding : utf-8 -*-
#= MediaEntry
#
# This class could just as easily also be known as MediaObject..
# and one day might become so.

class MediaEntry < MediaResource
  
  belongs_to                :media_file #, :include => :previews # TODO validates_presence # TODO on destroy, also destroy the media_file if this is the only related media_entry and snapshot
  belongs_to                :user
  has_many                  :snapshots

  alias :media_sets :parent_sets 

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

  def to_snapshot(user)
    if snapshotable?
      snapshots.first.destroy unless snapshots.empty?
      snapshots.create(user: user)
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
   meta_data_for_context.map do |md_bare|
      if other_entries.any? {|me| not me.meta_data.get(md_bare[:meta_key_id]).same_value?(md_bare[:value])}
        new_blank_media_entry.meta_data.build(:meta_key_id => md_bare[:meta_key_id], :keep_original_value => true)
      else
        new_blank_media_entry.meta_data.build(:meta_key_id => md_bare[:meta_key_id], :value => md_bare[:value])
      end
   end
 end

end
