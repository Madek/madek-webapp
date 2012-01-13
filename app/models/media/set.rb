# -*- encoding : utf-8 -*-
module Media

  class Set < ActiveRecord::Base # TODO rename to Media::Group
    include Resource

    set_table_name "media_sets"

#    def self.table_name_prefix
#      "media_"
#    end

    has_many :out_arcs, class_name: "Media::SetArc", :foreign_key => :parent_id
    has_many :in_arcs, class_name: "Media::SetArc", :foreign_key => :child_id

    has_many :child_sets, :through => :out_arcs, :source => :child
    has_many :parent_sets, :through => :in_arcs, :source => :parent
  
    belongs_to :user

    ######## MediaResource  >>>>
    belongs_to :media_resource 
    after_destroy {|r| r.media_resource.destroy if r.media_resource }
    before_create do |r|
      unless r.media_resource
        r.media_resource= (MediaResource.create owner: user) 
      end
    end
    after_create do 
      media_resource.created_at= created_at if media_resource.created_at > created_at
      media_resource.type = self.class.name
      media_resource.save!
    end
    ######## MediaResource <<<<


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
    
    before_save do
      owner ||=  user
    end

    def self.find_by_id_or_create_by_title(values, user)
      records = Array(values).map do |v|
                        if v.is_a?(Numeric) or !!v.match(/\A[+-]?\d+\Z/) # TODO path to String#is_numeric? method
                          a = where(:id => v).first
                        else
                          mk = MetaKey.find_by_label("title")
                          a = user.media_sets.create(:meta_data_attributes => [{:meta_key_id => mk.id, :value => v}])
                        end
                        a
                    end
      records.compact
    end

  ########################################################
  
    #default_scope order("updated_at DESC")
  
  ########################################################

    has_and_belongs_to_many :individual_contexts, :class_name => "MetaContext",
                                                  :join_table => :media_sets_meta_contexts,
                                                  :foreign_key => :media_set_id
    
    def inheritable_contexts
      parent_sets.map(&:individual_contexts).flatten.to_set.to_a # removes duplicates, I don't know how efficient .to_a.uniq is
    end
    
  ########################################################
  
    def to_s
      return "Beispielhafte Sets" if is_featured_set?

      s = "#{title} " 
      s += "- %s " % self.class.name.split('::').last # OPTIMIZE get class name without module name
      s += "(#{media_entries.count})" # TODO filter accessible ?? "(#{MediaResource.accessible_by_user(current_user).by_media_set(self).count})"
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
      
      json[:is_set] = true # TODO use :type instead of :is_set 
      
      if(with = options[:with])
        if(with[:set])
          if with[:set].has_key?(:child_sets) and (with[:set][:child_sets].is_a?(Hash) or not with[:set][:child_sets].to_i.zero?)
            json[:child_sets] = child_sets.as_json(options)
          end
          if with[:set].has_key?(:media_entries) and (with[:set][:media_entries].is_a?(Hash) or not with[:set][:media_entries].to_i.zero?)
            json[:media_entries] = media_entries.as_json(options)
          end
          if with[:set].has_key?(:creator) and (with[:set][:creator].is_a?(Hash) or not with[:set][:creator].to_i.zero?)
            json[:creator] = user.to_s
          end
          if with[:set].has_key?(:created_at) and (with[:set][:created_at].is_a?(Hash) or not with[:set][:created_at].to_i.zero?)
            json[:created_at] = created_at
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
        MediaResource.accessible_by_user(current_user).media_entries.by_media_set(self).map(&:id)
      else
        media_entry_ids
      end
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

    # TODO dry with MetaContext#used_meta_term_ids  
    def used_meta_term_ids(current_user = nil)
      accessible_media_entry_ids = if current_user
        MediaResource.accessible_by_user(current_user).media_entries.by_media_set(self).map(&:id)
      else
        media_entry_ids
      end
      meta_key_ids = individual_contexts.map{|ic| ic.meta_keys.for_meta_terms.map(&:id) }.flatten
      mds = MetaDatum.where(:meta_key_id => meta_key_ids, :resource_type => "MediaEntry", :resource_id => accessible_media_entry_ids)
      mds.collect(&:value).flatten.uniq.compact
    end
  
  end

end
