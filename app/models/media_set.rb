# -*- encoding : utf-8 -*-
class MediaSet < MediaResource

  has_many :children, :through => :out_arcs, :source => :child
  has_many :child_sets, :through => :out_arcs, :source => :child, conditions: "media_resources.type = 'MediaSet'"
  has_many :media_entries, :through => :out_arcs, :source => :child,  conditions: "media_resources.type = 'MediaEntry'"

  belongs_to :user

=begin #old??#
  def self.find_by_id_or_create_by_title(values, user)
    records = Array(values).map do |v|
                      if v.is_a?(Numeric) or (v.respond_to?(:is_integer?) and v.is_integer?)
                        find_by_id(v)
                      else
                        user.media_sets.create(:meta_data_attributes => [{:meta_key_label => "title", :value => v}])
                      end
                  end
    records.compact
  end
=end

  # TODO remove, it's used only on tests!
  # FIXME this only fetches the first set with that title,
  # but there could be many sets with the same title 
  def self.find_by_title(title)
    MediaSet.joins(:meta_data => :meta_key).where(:meta_keys => {:label => "title"}, :meta_data => {:string => title}).first
  end

########################################################

  has_and_belongs_to_many :individual_contexts, :class_name => "MetaContext",
                                                :join_table => :media_sets_meta_contexts,
                                                :foreign_key => :media_set_id
  
  def inheritable_contexts
    parent_sets.flat_map(&:individual_contexts).to_set.to_a # removes duplicates, I don't know how efficient .to_a.uniq is
  end

  def individual_and_inheritable_contexts
    (individual_contexts | inheritable_contexts).sort
  end

### Settings ##########################################

  store :settings

  ACCEPTED_VARS = {
    :layout => {:possible_values => [:miniature, :grid, :list], :default => :grid},
    :sorting => {:possible_values => [:created_at, :updated_at, :title, :author], :default => :updated_at}
  }

  validate do
    unless settings.blank?
      errors.add(:settings, "Invalid key") unless (settings.keys - ACCEPTED_VARS.keys).empty?
      settings.each_pair do |k,v|
        errors.add(:settings, "Invalid value") unless ACCEPTED_VARS[k][:possible_values].include? v
      end
    end 
  end

### Size ##############################################
  
  def size user=nil
    descendants = GraphQueries.descendants(self)
    descendants = descendants.accessible_by_user(user) if user
    descendants.size
  end

########################################################

  #tmp# this is currently up on MediaResource
  #scope :top_level, joins("LEFT JOIN media_resource_arcs ON media_resource_arcs.child_id = media_resources.id").
  #                  where(:media_resource_arcs => {:parent_id => nil})

  #tmp# FIXME count.size # scope :not_top_level, joins(:in_arcs).group("media_resource_arcs.child_id")

########################################################

  def to_s
    return "Beispielhafte Sets" if is_featured_set?
    title_and_count
  end
  
  def title_and_count
    "#{title} (#{media_entries.count})" # TODO filter accessible ?? "(#{media_entries.accessible_by_user(current_user).count})"
  end

########################################################

  def get_media_file(user)
    if out_arcs.where(cover: true).empty?
      # NOTE this is the fallback in case no cover is set yet.
      # Because the personas sql dump on test, we cannot set automatically in MediaResourceArcs#after_create (as it should)
      # then instead of a callback and a migration, we store on the fly the oldest media_entry child_arc as cover
      arc = out_arcs.joins(:child).where(:media_resources => {:type => 'MediaEntry'}).order("media_resource_arcs.id ASC").readonly(false).first
      arc.update_attributes(cover: true) if arc
    end
    
    media_entries.accessible_by_user(user).where(media_resource_arcs: {cover: true}).first.try(:media_file)
  end

########################################################

  def is_featured_set?
    !self.id.nil? and self.id == AppSettings.featured_set_id
  end

########################################################

  # TODO dry with MetaContext#abstract  
  def abstract(min_media_entries = nil, current_user = nil)
    min_media_entries ||= media_entries.count.to_f * 50 / 100
    accessible_media_entry_ids = if current_user
      media_entries.accessible_by_user(current_user).pluck("media_resources.id")
    else
      media_entry_ids
    end
    meta_key_ids = individual_contexts.flat_map(&:meta_key_ids)
    h = {} #1005# TODO upgrade to Ruby 1.9 and use ActiveSupport::OrderedHash.new
    mds = MetaDatum.where(:meta_key_id => meta_key_ids, :media_resource_id => accessible_media_entry_ids)
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
    accessible_media_entry_ids = if current_user
      media_entries.accessible_by_user(current_user).pluck("media_resources.id")
    else
      media_entry_ids
    end
    meta_key_ids = individual_contexts.flat_map{|ic| ic.meta_keys.for_meta_terms.pluck("meta_keys.id") }
    mds = MetaDatum.where(:meta_key_id => meta_key_ids, :media_resource_id => accessible_media_entry_ids)
    mds.flat_map(&:meta_term_ids).uniq
  end

end
