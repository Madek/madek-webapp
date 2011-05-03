class Media::Project < Media::Set

  has_and_belongs_to_many :individual_contexts, :class_name => "MetaContext",
                                                :join_table => :media_projects_meta_contexts,
                                                :foreign_key => :media_project_id


  # TODO this is used to construct url_path and partials, find a better solution!!! (route alias, ...)
  def self.model_name
    superclass.model_name
  end

  def abstract
    meta_key_ids = individual_contexts.map(&:meta_key_ids).flatten
    h = {}
    #old# mds = media_entries.collect{|me| me.meta_data.where(:meta_key_id => meta_keys) }.flatten
    mds = MetaDatum.where(:meta_key_id => meta_key_ids, :resource_type => "MediaEntry", :resource_id => media_entry_ids)
    mds.each do |md|
      h[md.meta_key_id] ||= [] # TODO md.meta_key
      h[md.meta_key_id] << md.value
    end
    c = media_entries.count.to_f * 50 / 100
    h.delete_if {|k, v| v.size < c }
    h.each_pair {|k, v| h[k] = v.flatten.group_by {|x| x}.delete_if {|k, v| v.size < c }.keys }
    h.delete_if {|k, v| v.blank? }
    h.collect {|k, v| meta_data.build(:meta_key_id => k, :value => v) }
  end

end
