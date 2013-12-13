# -*- encoding : utf-8 -*-
class MediaSet < MediaResourceCollection

  has_many :child_media_resources, :through => :out_arcs, :source => :child
  has_many :highlights,->{where('media_resource_arcs.highlight = ?',true)}, :through => :out_arcs, :source => :child

  def included_resources_accessible_by_user  user, action
    child_media_resources.accessible_by_user(user,action)
  end


########################################################

  has_and_belongs_to_many :individual_contexts, class_name: "MetaContext",
                                                join_table: :media_sets_meta_contexts,
                                                foreign_key: :media_set_id, 
                                                association_foreign_key: :meta_context_name
  
  def inheritable_contexts
    parent_sets.flat_map(&:individual_contexts).to_set.to_a # removes duplicates, I don't know how efficient .to_a.uniq is
  end

  def individual_and_inheritable_contexts
    (individual_contexts | inheritable_contexts).sort
  end

  def categories
    self.child_media_resources.filter_sets
  end

### Settings ##########################################

  store :settings

  ACCEPTED_SETTINGS = {
    :layout => {:possible_values => [:miniature, :grid, :list], :default => :grid},
    :sorting => {:possible_values => [:created_at, :updated_at, :title, :author], :default => :updated_at}
  }


  validate :validate_settings

  def validate_settings 
    if _settings = ((not settings.blank?) and settings.deep_symbolize_keys)
      unless (_settings.keys - ACCEPTED_SETTINGS.deep_symbolize_keys.keys).empty?
        errors.add(:settings, "Invalid key") 
      end
      _settings.each_pair do |k,v|
        if ACCEPTED_SETTINGS[k][:possible_values] and \
          not ACCEPTED_SETTINGS[k][:possible_values].include?(v)
          errors.add(:settings, "Invalid value") 
        end
      end
    end 
  end

########################################################

  def to_s
    if is_featured_set? 
      "Beispielhafte Sets"
    else
      title_and_count
    end
  end

  def title_and_count
    "#{title} (#{child_media_resources.media_entries.count})" 
  end

########################################################

  def cover(user)
    child_media_resources.media_entries.accessible_by_user(user,:view).joins(:in_arcs).where(media_resource_arcs: {cover: true}).first
  end

  def get_media_file(user)
    unless out_arcs.where(cover: true).exists?
      # NOTE this is the fallback in case no cover is set yet.
      # Because the personas sql dump on test, we cannot set automatically in MediaResourceArcs#after_create (as it should)
      # then instead of a callback and a migration, we store on the fly the oldest media_entry child_arc as cover
      arc = out_arcs.joins(:child).where(:media_resources => {:type => 'MediaEntry'}).order("media_resource_arcs.id ASC").readonly(false).first
      arc.update_attributes(cover: true) if arc
    end

    cover(user).try(:media_file)
  end

  def media_type
    self.type.gsub(/Media/, '')
  end

########################################################

  def is_featured_set?
    !self.id.nil? and self.id == AppSettings.first.featured_set_id
  end

########################################################

  # TODO dry with MetaContext#abstract  
  def abstract(min_media_entries = nil, current_user = nil)
    min_media_entries ||= media_entries.count.to_f * 50 / 100
    meta_key_ids = individual_contexts.map do |c|
      c.meta_keys.for_meta_terms.pluck("meta_keys.id")
    end.flatten
    h = {} #1005# TODO upgrade to Ruby 1.9 and use ActiveSupport::OrderedHash.new
    mds = MetaDatum.where(:meta_key_id => meta_key_ids, :media_resource_id => accessible_media_entry_ids_by(current_user))
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

  # TODO dry with MetaContext#used_meta_term_ids  
  def used_meta_term_ids(current_user = nil)
    meta_key_ids = individual_contexts.flat_map{|ic| ic.meta_keys.for_meta_terms.pluck("meta_keys.id") }
    mds = MetaDatum.where(:meta_key_id => meta_key_ids, :media_resource_id => accessible_media_entry_ids_by(current_user))
    mds.flat_map(&:meta_term_ids).uniq
  end

  private
  
  def accessible_media_entry_ids_by(current_user)
    if current_user
      child_media_resources.media_entries.accessible_by_user(current_user,:view)
    else
      child_media_resources.media_entries
    end.pluck("media_resources.id")
  end

end
