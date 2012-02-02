# -*- encoding : utf-8 -*-
class MediaSet < MediaResource

  has_many :out_arcs, :class_name => "MediaSetArc", :foreign_key => :parent_id
  has_many :in_arcs, :class_name => "MediaSetArc", :foreign_key => :child_id

  has_many :child_sets, :through => :out_arcs, :source => :child
  has_many :parent_sets, :through => :in_arcs, :source => :parent

  belongs_to :user
  has_and_belongs_to_many :media_entries, :join_table => "media_entries_media_sets",
                                          :foreign_key => "media_set_id" do
    def push_uniq(members)
      i = 0
      Array(members).each do |member|
        next if exists? member
        push member
        i += 1
      end
      i
    end
  end
  
  def self.find_by_id_or_create_by_title(values, user)
    records = Array(values).map do |v|
                      if v.is_a?(Numeric) or !!v.match(/\A[+-]?\d+\Z/) # TODO path to String#is_numeric? method
                        where(:id => v).first
                      else
                        user.media_sets.create(:meta_data_attributes => [{:meta_key_label => "title", :value => v}])
                      end
                  end
    records.compact
  end

  # FIXME this only fetches the first set with that title,
  # but there could be many sets with the same title 
  def self.find_by_title(title)
    MediaSet.joins(:meta_data => :meta_key).
      where(:meta_data => {:meta_keys => {:label => "title"}, :value => title.to_yaml}).first
  end

########################################################

  has_and_belongs_to_many :individual_contexts, :class_name => "MetaContext",
                                                :join_table => :media_sets_meta_contexts,
                                                :foreign_key => :media_set_id
  
  def inheritable_contexts
    parent_sets.map(&:individual_contexts).flatten.to_set.to_a # removes duplicates, I don't know how efficient .to_a.uniq is
  end
  
########################################################

  scope :top_level, joins("LEFT JOIN media_set_arcs ON media_set_arcs.child_id = media_resources.id").
                    where(:media_set_arcs => {:parent_id => nil})

  #tmp# FIXME count.size # scope :not_top_level, joins(:in_arcs).group("media_set_arcs.child_id")

########################################################

  def to_s
    return "Beispielhafte Sets" if is_featured_set?
    title_and_count
  end
  
  def title_and_count
    "#{title} (#{media_entries.count})" # TODO filter accessible ?? "(#{media_entries.accessible_by_user(current_user).count})"
  end

########################################################

  def is_featured_set?
    !self.id.nil? and self.id == AppSettings.featured_set_id
  end

  def self.featured_set
    where(:id => AppSettings.featured_set_id).first
  end

  def self.featured_set=(media_set)
    AppSettings.featured_set_id = media_set.id
  end

########################################################

  def as_json(options={})
    options ||= {}
    json = super(options)
    
    json[:is_set] = true # TODO use :type instead of :is_set  # TODO drop as default
    if(with = options[:with])
      if(with[:media_set] and with[:media_set].is_a?(Hash))
        if with[:media_set].has_key?(:child_sets) and (with[:media_set][:child_sets].is_a?(Hash) or not with[:media_set][:child_sets].to_i.zero?)
          json[:child_sets] = child_sets.accessible_by_user(options[:current_user]).as_json(:with => {:media_set => with[:media_set][:media_sets]})
        end
        if with[:media_set].has_key?(:media_entries) and (with[:media_set][:media_entries].is_a?(Hash) or not with[:media_set][:media_entries].to_i.zero?)
          json[:media_entries] = media_entries.accessible_by_user(options[:current_user]).as_json(:with => {:media_entry => with[:media_set][:media_entries]})
        end
        if with[:media_set].has_key?(:media_resources) and (with[:media_set][:media_resources].is_a?(Hash) or not with[:media_set][:media_resources].to_i.zero?)
          json[:media_resources] = media_entries.accessible_by_user(options[:current_user]).as_json(:with => {:media_resource => with[:media_set][:media_resources]})
          json[:media_resources] += child_sets.accessible_by_user(options[:current_user]).as_json({:with => {:media_resource => with[:media_set][:media_resources]}}.merge(:current_user => options[:current_user]))
        end
        if with[:media_set].has_key?(:creator) and (with[:media_set][:creator].is_a?(Hash) or not with[:media_set][:creator].to_i.zero?)
          json[:creator] = user.as_json(:only => :id, :methods => :name)
        end
        if with[:media_set].has_key?(:created_at) and (with[:media_set][:created_at].is_a?(Hash) or not with[:media_set][:created_at].to_i.zero?)
          json[:created_at] = created_at
        end
        if with[:media_set].has_key?(:title) and (with[:media_set][:title].is_a?(Hash) or not with[:media_set][:title].to_i.zero?)
          json[:title] = meta_data.get_value_for("title")
        end
      end
    end

    json
end

########################################################

  # TODO dry with MetaContext#abstract  
  def abstract(min_media_entries = nil, current_user = nil)
    min_media_entries ||= media_entries.count.to_f * 50 / 100
    accessible_media_entry_ids = if current_user
      media_entries.accessible_by_user(current_user).map(&:id)
    else
      media_entry_ids
    end
    meta_key_ids = individual_contexts.map(&:meta_key_ids).flatten
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
      media_entries.accessible_by_user(current_user).map(&:id)
    else
      media_entry_ids
    end
    meta_key_ids = individual_contexts.map{|ic| ic.meta_keys.for_meta_terms.map(&:id) }.flatten
    mds = MetaDatum.where(:meta_key_id => meta_key_ids, :media_resource_id => accessible_media_entry_ids)
    mds.collect(&:value).flatten.uniq.compact
  end

end
