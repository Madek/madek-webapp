# -*- encoding : utf-8 -*-

class MediaResource < ActiveRecord::Base

  has_many :userpermissions, :dependent => :destroy
  has_many :grouppermissions, :dependent => :destroy

  belongs_to :user 
  belongs_to :media_file
  belongs_to :upload_session

  ### Permissionset >>>
  belongs_to :permissionset
  before_create do |r| 
    r.permissionset= Permissionset.create unless r.permissionset 
  end
  ### Permissionset <<<

  #has_one :media_entry
  #has_one :media_set, :class_name => MediaSet.name

  ### only for media_entries
  belongs_to :upload_session
  #has_and_belongs_to_many :favorites, :class_name => "MediaEntry", :join_table => "favorites"
  ###
  
  ### only for media_sets
  #tmp# has_and_belongs_to_many :media_entries, :join_table => "media_entries_media_sets", :foreign_key => "media_set_id"
  ###
  
  # default_scope order("updated_at DESC")

  ################################################################

  scope :media_entries, where(:type => "MediaEntry")
  scope :media_sets, where(:type => "MediaSet")

  ################################################################

  #scope :by_user, lambda {|user| media_entries.joins(:upload_session).where(:upload_sessions => {:user_id => user}) } 
  scope :by_user, lambda {|user| where(:user_id => user) } 
  #scope :not_by_user, lambda {|user| media_entries.joins(:upload_session).where(["upload_sessions.user_id != ?", user]) } 
  scope :not_by_user, lambda {|user| where(["user_id != ?", user]) }

  ################################################################
  
  scope :favorites_for_user, lambda {|user|
    media_entries.
    joins("RIGHT JOIN favorites ON media_resources.id = favorites.media_entry_id").
    where(:favorites => {:user_id => user})
  }

  ################################################################

  scope :by_media_set, lambda {|media_set|
    #tmp#
    #SELECT `media_resources`.* FROM `media_resources`
    #left JOIN media_entries_media_sets ON media_resources.id = media_entries_media_sets.media_entry_id and `media_entries_media_sets`.`media_set_id` = 347
    #inner JOIN `media_set_links` ON media_resources.id = `media_set_links`.`descendant_id` and `media_set_links`.`ancestor_id` = 347 AND `media_set_links`.`direct` = 1;

    #old#
    #joins("INNER JOIN media_entries_media_sets ON media_resources.id = media_entries_media_sets.media_entry_id").
    #where(:media_entries_media_sets => {:media_set_id => media_set})

    where("(media_resources.id, media_resources.type) IN " \
            "(SELECT media_entry_id AS id, 'MediaEntry' AS type FROM media_entries_media_sets " \
              "WHERE media_set_id = ? " \
            "UNION " \
              "SELECT child_id AS id, 'MediaSet' AS type FROM media_set_arcs " \
                "WHERE parent_id = ? )",
          media_set.id, media_set.id);
  }

  ################################################################

  scope :search, lambda {|q|
    sql = joins("LEFT JOIN full_texts ON (media_resources.id, media_resources.type) = (full_texts.resource_id, full_texts.resource_type)")
    #with fulltext index#
    #if q.size > 3
    #  sql.where("MATCH (text) AGAINST (?)", q)
    #else
    #  sql.where("text LIKE ?", "%#{q}%")
    #end
    w = q.split.map{|x| "text LIKE '%#{x}%'" }.join(' AND ')
    sql.where(w)
  }

  ################################################################
  
  def self.reindex
    all.map(&:reindex).uniq
  end
  
  def self.filter_media_file(options = {})
    sql = media_entries.joins("RIGHT JOIN media_files ON media_resources.media_file_id = media_files.id")
    
    if options[:width] and not options[:width][:value].blank?
      operator = case options[:width][:operator]
        when "gt"
          ">"
        when "lt"
          "<"
        else
          "="
      end
      sql = sql.where("media_files.width #{operator} ?", options[:width][:value])
    end

    if options[:height] and not options[:height][:value].blank?
      operator = case options[:height][:operator]
        when "gt"
          ">"
        when "lt"
          "<"
        else
          "="
      end
      sql = sql.where("media_files.height #{operator} ?", options[:height][:value])
    end

    unless options[:orientation].blank?
      operator = case options[:orientation].to_i
        when 0
          "<"
        when 1
          ">"
      end
      sql = sql.where("media_files.height #{operator} media_files.width")
    end

    sql    
  end


  def self.accessible_by_user(user, action = :view)
    i = 2 ** Permission::ACTIONS.index(action)


    if SQLHelper::adapter_is_mysql? 
      where("(media_resources.id, media_resources.type) NOT IN " \
            "(SELECT resource_id, resource_type FROM permissions " \
            "USE INDEX (index_permissions_on_resource__and_subject) " \
            "WHERE (subject_type = 'User' AND subject_id = ?) " \
            "AND NOT #{SQLHelper.bitwise_is('action_bits',i)} AND #{SQLHelper.bitwise_is('action_mask',i)}) " \
            "AND (media_resources.id, media_resources.type) IN " \
            "(SELECT resource_id, resource_type FROM permissions " \
            "USE INDEX (index_permissions_on_resource__and_subject) " \
            "WHERE (subject_type IS NULL " \
            "OR (subject_type = 'Group' AND subject_id IN (?)) " \
            "OR (subject_type = 'User' AND subject_id = ?)) " \
            "AND   #{SQLHelper.bitwise_is('action_bits',i)} AND #{SQLHelper.bitwise_is('action_mask',i)}) ",
            user.id, user.group_ids, user.id);

    else
      where("(media_resources.id, media_resources.type) NOT IN " \
            "(SELECT resource_id, resource_type from permissions " \
            "WHERE (subject_type = 'User' AND subject_id = ?) " \
            "AND NOT #{SQLHelper.bitwise_is('action_bits',i)} AND #{SQLHelper.bitwise_is('action_mask',i)}) " \
            "AND (media_resources.id, media_resources.type) IN " \
            "(SELECT resource_id, resource_type from permissions " \
            "WHERE (subject_type IS NULL " \
            "OR (subject_type = 'Group' AND subject_id IN (?)) " \
            "OR (subject_type = 'User' AND subject_id = ?)) " \
            "AND   #{SQLHelper.bitwise_is('action_bits',i)} AND #{SQLHelper.bitwise_is('action_mask',i)}) ",
            user.id, user.group_ids, user.id);
    end
  end

end
