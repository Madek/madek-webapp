# -*- encoding : utf-8 -*-
class MediaEntriesController < ApplicationController

  before_filter :pre_load
  before_filter :authorized?, :except => [:index, :media_sets, :favorites, :toggle_favorites, :keywords] #old# :only => [:show, :edit, :update, :destroy]
  
  def index
    # madek11
    theme "madek11"
    # filtering attributes
    with = {}
    media_entries = if @user
                      if logged_in?
                        if @user == current_user
                          # all media_entries I can see and uploaded by me
                          ids = Permission.accessible_by_user("MediaEntry", current_user)
                          MediaEntry.by_user(current_user).by_ids(ids)
                        else
                          # intersection between me and somebody viewable media_entries
                          ids = Permission.accessible_by_user("MediaEntry", current_user) & Permission.accessible_by_user("MediaEntry", @user)
                          MediaEntry.by_ids(ids)
                        end
                      else
                        # intersection between public media_entries and somebody viewable media_entries
                        
                        #old#0903# 
                        #ids = Permission.accessible_by_user("MediaEntry", @user)
                        #MediaEntry.public.by_ids(ids)

                        ids = Permission.accessible_by_user("MediaEntry", @user) & Permission.accessible_by_all("MediaEntry")
                        MediaEntry.by_ids(ids)
                      end
                    else
                      if logged_in?
                        ids = Permission.accessible_by_user("MediaEntry", current_user)
                        if params[:not_by_current_user]
                          # all media_entries I can see but not uploaded by me
                          MediaEntry.not_by_user(current_user).by_ids(ids)
                        else
                          # all media_entries I can see
                          MediaEntry.by_ids(ids)
                        end
                      else
                        # all public media_entries
                        
                        #old#0903#
                        # MediaEntry.public
                        
                        ids = Permission.accessible_by_all("MediaEntry")
                        MediaEntry.by_ids(ids)
                      end
                    end

#old 1003#
#    if @media_set
#      if @media_set.dynamic?
#        params[:query] = @media_set.query
#      else
#        with[:media_set_ids] = @media_set.id
#      end
#    end

    if @media_file
      with[:media_file_id] = @media_file.id
    end

    # TODO params[:search][:query], params[:search][:page], params[:search][:per_page]
#temp#    
#      if params[:per_page].blank?
#        session[:per_page] ||= PER_PAGE.first
#        params[:per_page] = session[:per_page]
#      else
#        session[:per_page] = params[:per_page]
#      end
    params[:per_page] ||= PER_PAGE.first

    @media_entries = media_entries.search params[:query],
                                         { #TODO activate this if you need advanced search# :match_mode => :extended2,
                                           :page => params[:page], :per_page => params[:per_page].to_i, :retry_stale => true,
                                           :with => with,
                                           :star => true,
                                    #temp# :order => (params[:order].blank? ? nil : params[:order]), # OPTIMIZE params[:search][:order]
                                           :include => [:default_permission,
                                                        {:media_file => :preview_small}] }
#temp#
#    @facets = MediaEntry.facets params[:query], :match_mode => :extended2,
#                                                 :with => with
    
    respond_to do |format|
      format.html
      format.js {
        render :partial => 'index'
      }
      format.xml { render :xml=> @media_entries.to_xml(:include => {:meta_data => {:include => :meta_key}} ) }
    end

  end
    
  def show
    respond_to do |format|
      format.html
      format.js { render @media_entry }
      format.xml { render :xml=> @media_entry.to_xml(:include => {:meta_data => {:include => :meta_key}} ) }
    end
  end

#####################################################
# Authenticated Area

  def edit
    
  end

#  # NOTE accepting and destroying an array of media_entries
#  def multiple_destroy
#    MediaEntry.suspended_delta do
#      @deleted = []
#      Array(@media_entry).each do |media_entry|
#        next unless current_user == media_entry.user # TODO acl
#        @deleted << media_entry.destroy
#      end
#    end
#
#    respond_to do |format|
#      format.html { redirect_to media_entries_path }
#      format.js { render :json => @deleted.collect(&:id) }
#    end
#  end

  def destroy
    @media_entry.destroy
    flash[:notice] = "Der Medieneintrag wurde gelöscht."

    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

#####################################################

  def edit_tms
    
  end

  def to_snapshot
    @media_entry.to_snapshot if current_user.groups.is_member?("Expert")
    redirect_to @media_entry
  end

#####################################################

  # OPTIMIZE media_set ACL
  def media_sets
    if request.post?
      Media::Set.find_by_id_or_create_by_title(params[:media_set_ids], current_user).each do |media_set|
        next unless Permission.authorized?(current_user, :edit, media_set) # (Media::Set ACL!)
        media_set.media_entries.push_uniq @media_entry
      end
      redirect_to @media_entry
    elsif request.delete?
      if Permission.authorized?(current_user, :edit, @media_set) # (Media::Set ACL!)
        @media_set.media_entries.delete(@media_entry)
        #old 0310# @media_entry.sphinx_reindex
        render :nothing => true # TODO redirect_to @media_set
      else
        # OPTIMIZE
        render :nothing => true, :status => 403
      end 
    end
  end

  # TODO refactor to users_controller ??
  def favorites
    theme "madek11"
    if request.post?
      current_user.favorites << @media_entry
      # current_user.favorites.toggle(@media_entry) -- for madek11
      respond_to do |format|
        format.js { render :partial => "favorite_link", :locals => {:media_entry => @media_entry} }
      end
    # request.delete will be obsolete in madek11 
    elsif request.delete?
      current_user.favorites.delete(@media_entry)
      respond_to do |format|
        format.js { render :partial => "favorite_link", :locals => {:media_entry => @media_entry} }
      end
    else
      # TODO refactor to index method and make it searcheable
      @media_entries = current_user.favorites.paginate(:page => params[:page])
      respond_to do |format|
        format.html
      end
    end
  end
  
  
  #tmp # until madek11 theme complete
  def toggle_favorites
    theme "madek11"
    current_user.favorites.toggle(@media_entry)
    respond_to do |format|
      format.js { render :partial => "favorite_link", :locals => {:media_entry => @media_entry} }
    end
  end

  def keywords
#old#
##select *, count(*) from keywords group by term_id;
##select *, count(*) from keywords where user_id = 159123 group by term_id;
##select *, count(*) from keywords where exists (select * from keywords as t2 where t2.term_id = keywords.term_id AND t2.user_id = 159123) group by term_id;
    @all_keywords = Keyword.select("*, COUNT(*) AS q").group(:meta_term_id).order("q DESC")
    @my_keywords = Keyword.select("*, COUNT(*) AS q").where(:user_id => current_user).group(:meta_term_id).order("q DESC")
    
#old#
##SELECT t1.*, COUNT(*) AS q, t2.user_id AS u FROM `keywords` AS t1 LEFT JOIN keywords AS t2 ON t1.term_id = t2.term_id AND t2.user_id = 159123 GROUP BY t1.term_id ORDER BY q DESC;
#    @keywords = Keyword.select("keywords.*, COUNT(*) AS q, t2.user_id AS u").
#                joins("LEFT JOIN keywords AS t2 ON keywords.term_id = t2.term_id AND t2.user_id = #{current_user.id}").
#                group(:meta_term_id)

##SELECT *, COUNT(*) AS q, (SELECT user_id FROM keywords AS t2 WHERE t2.term_id = keywords.term_id AND t2.user_id = 159123 LIMIT 1) AS u FROM `keywords` GROUP BY term_id ORDER BY q DESC;
#    @keywords = Keyword.select("*, COUNT(*) AS q, (SELECT user_id FROM keywords AS t2 WHERE t2.term_id = keywords.term_id AND t2.user_id = #{current_user.id} LIMIT 1) AS u").
#                group(:meta_term_id).order("q DESC")
##SELECT *, COUNT(*) AS q, exists (SELECT * FROM keywords AS t2 WHERE t2.term_id = keywords.term_id AND t2.user_id = 159123) AS u FROM `keywords` GROUP BY term_id ORDER BY q DESC;
#    @keywords = Keyword.select("*, COUNT(*) AS q, exists (SELECT * FROM keywords AS t2 WHERE t2.term_id = keywords.term_id AND t2.user_id = #{current_user.id}) AS u").
#                group(:meta_term_id).order("q DESC")
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
#####################################################

  def remove_multiple
#old 1003#
#    @media_entries.each do |media_entry|
#      @media_set.media_entries.delete(media_entry)
#      media_entry.sphinx_reindex
#    end
    @media_set.media_entries.delete(@media_entries)
    redirect_to media_set_url(@media_set)
  end
  
  def edit_multiple
    theme "madek11"
    
    session[:batch_origin_uri] = request.env['HTTP_REFERER']
    # custom hash for jQuery json templates
    @info_to_json = @media_entries.map do |me|
      me.attributes.merge!(me.get_basic_info)
    end.to_json
  end
  
  def update_multiple
    MediaEntry.suspended_delta do
      @media_entries.each do |media_entry|
        if media_entry.update_attributes(params[:resource], current_user)
          flash[:notice] = "Die Änderungen wurden gespeichert." # TODO appending success message and resource reference (id, title)
        else
          flash[:error] = "Die Änderungen wurden nicht gespeichert." # TODO appending success message and resource reference (id, title)
        end
      end
    end
    
    redirect_to (session[:batch_origin_uri] || media_entries_path) # TODO media_entries_path(:media_entries_id => @media_entries)
  end
  
  def edit_multiple_permissions
    theme "madek11"
    session[:batch_origin_uri] = request.env['HTTP_REFERER']
    @combined_permissions = Permission.compare(@media_entries)
  end

  def update_multiple_permissions
    theme "madek11"
    
      @media_entries.each do |media_entry|
        media_entry.permissions.delete_all
    
        actions = params[:subject]["nil"]
        media_entry.permissions.build(:subject => nil).set_actions(actions)
  
        ["User", "Group"].each do |key|
          params[:subject][key].each_pair do |subject_id, actions|
            media_entry.permissions.build(:subject_type => key, :subject_id => subject_id).set_actions(actions)
          end if params[:subject][key]
        end
        
        media_entry.permissions.where(:subject_type => current_user.class.base_class.name, :subject_id => current_user.id).first.set_actions({:manage => true})
      end

    flash[:notice] = "Die Zugriffsberechtigungen wurden erflogreich gespeichert."    
    redirect_to (session[:batch_origin_uri] || media_entries_path)

  end
  
#####################################################

#old#
#  def query_count
#    # TODO refactor to the pre_load
#    conditions = {}
#    conditions[:is_public] = true
#    if @user
#      conditions[:user_id] = @user.id
#      conditions[:is_public] = nil if @user == current_user
#    end
#
#    c = MediaEntry.search_count params[:query], :match_mode => :extended2,
#                                                :conditions => conditions
##    render :update do |page|
##      page.replace_html  'query_count', c
##    end
#    render :text => "#{c} entries"
#  end

#####################################################

  private

  def authorized?
    conditions = [] # OPTIMIZE
    action = request[:action].to_sym
    case action
      when :new
        action = :create
      when :show
        action = :view
      when :edit, :update
        action = :edit
      when :destroy
        action = :edit # TODO :delete
      when :edit_tms
        conditions << current_user.groups.is_member?("Expert")
        action = :edit
      when :to_snapshot
        not_authorized! unless current_user.groups.is_member?("Expert")
        return
      when :edit_multiple, :update_multiple, :edit_multiple_permissions, :update_multiple_permissions
        not_authorized! if @media_entries.empty?
        return
      when :remove_multiple
        not_authorized! unless Permission.authorized?(current_user, :edit, @media_set)
        return
    end
    resource = @media_entry
    not_authorized! unless Permission.authorized?(current_user, action, resource) and conditions.all?
    # TODO super ??
  end
  
  def pre_load
      # TODO test; useful for will_paginate and forwarding links; refactor to application_controller?
      params.delete_if {|k,v| v.blank? }
      action = request[:action].to_sym

      params[:media_entry_id] ||= params[:id] unless params[:id].blank?
      
      @user = User.find(params[:user_id]) unless params[:user_id].blank?
      @context = MetaContext.find(params[:context_id]) unless params[:context_id].blank?
      @media_set = (@user? @user.media_sets : Media::Set).find(params[:media_set_id]) unless params[:media_set_id].blank? # TODO shallow
      @media_file = MediaFile.find(params[:media_file_id]) unless params[:media_file_id].blank?

      if not params[:media_entry_ids].blank?
        selected_ids = params[:media_entry_ids].split(",").map{|e| e.to_i }
        @media_entries = case action
          when :edit_multiple, :update_multiple
            editable_ids = Permission.accessible_by_user(MediaEntry, current_user, :edit)
            MediaEntry.where(:id => (selected_ids & editable_ids))
          when :edit_multiple_permissions, :update_multiple_permissions
            manageable_ids = Permission.accessible_by_user(MediaEntry, current_user, :manage)
            MediaEntry.where(:id => (selected_ids & manageable_ids))
          when :remove_multiple
            MediaEntry.where(:id => selected_ids)
        end
      elsif not params[:media_entry_id].blank?
        @media_entry =  if @media_set
                          @media_set.media_entries.find(params[:media_entry_id])
                        elsif @user
                          @user.media_entries.find(params[:media_entry_id])
                        # TODO if @user and @media_set ??
                        elsif @media_file # TODO still needed?
                          @media_file.media_entries.find(params[:media_entry_id])
                        else
                          MediaEntry.find(params[:media_entry_id])
                        end
      end
  end


end
