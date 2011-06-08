class Media::Project < Media::Set

  has_and_belongs_to_many :individual_contexts, :class_name => "MetaContext",
                                                :join_table => :media_projects_meta_contexts,
                                                :foreign_key => :media_project_id


  # TODO this is used to construct url_path and partials, find a better solution!!! (route alias, ...)
  def self.model_name
    superclass.model_name
  end

  # TODO scope accessible media_entries only
  def abstract(min_media_entries = nil, accessible_media_entry_ids = nil)
    min_media_entries ||= media_entries.count.to_f * 50 / 100
    accessible_media_entry_ids ||= media_entry_ids
    meta_key_ids = individual_contexts.map(&:meta_key_ids).flatten
    h = {} #1005# TODO upgrade to Ruby 1.9 and use ActiveSupport::OrderedHash.new
    mds = MetaDatum.where(:meta_key_id => meta_key_ids, :resource_type => "MediaEntry", :resource_id => accessible_media_entry_ids)
    mds.each do |md|
      h[md.meta_key_id] ||= [] # TODO md.meta_key
      h[md.meta_key_id] << md.value
    end
    h.delete_if {|k, v| v.size < min_media_entries }
    h.each_pair {|k, v| h[k] = v.flatten.group_by {|x| x}.delete_if {|k, v| v.size < min_media_entries }.keys }
    h.delete_if {|k, v| v.blank? }
    #1005# return h.collect {|k, v| meta_data.build(:meta_key_id => k, :value => v) }
    b = []
    h.each_pair {|k, v| b[meta_key_ids.index(k)] = meta_data.build(:meta_key_id => k, :value => v) }
    return b.compact
  end

  def used_meta_term_ids(accessible_media_entry_ids = nil)
    accessible_media_entry_ids ||= media_entry_ids
    meta_key_ids = individual_contexts.map{|ic| ic.meta_keys.for_meta_terms.map(&:id) }.flatten
    mds = MetaDatum.where(:meta_key_id => meta_key_ids, :resource_type => "MediaEntry", :resource_id => accessible_media_entry_ids)
    mds.collect(&:value).flatten.uniq.compact
  end

end
