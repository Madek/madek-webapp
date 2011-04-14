# -*- encoding : utf-8 -*-
class MediaEntriesController < ApplicationController

  before_filter :pre_load, :except => [:edit_multiple, :update_multiple, :remove_multiple, :edit_multiple_permissions]
  before_filter :pre_load_for_batch, :only => [:edit_multiple, :update_multiple, :remove_multiple, :edit_multiple_permissions]
  before_filter :authorized?, :except => [:index, :media_sets, :favorites, :toggle_favorites, :keywords] #old# :only => [:show, :edit, :update, :destroy]
  after_filter :store_location, :only => [:index]

  def index
    # TODO params[:search][:query], params[:search][:page], params[:search][:per_page]
    #temp#    
    #      if params[:per_page].blank?
    #        session[:per_page] ||= PER_PAGE.first
    #        params[:per_page] = session[:per_page]
    #      else
    #        session[:per_page] = params[:per_page]
    #      end

    params[:per_page] ||= PER_PAGE.first

    ########################################################################
    # Approach 1: filtering ids before search

#    media_entries = if @user
#                      if logged_in?
#                        if @user == current_user
#                          # all media_entries I can see and uploaded by me
#                          viewable_ids = Permission.accessible_by_user("MediaEntry", current_user)
#                          MediaEntry.by_user(current_user).by_ids(viewable_ids)
#                        else
#                          # intersection between me and somebody viewable media_entries => WRONG!!!
#                          viewable_ids = Permission.accessible_by_user("MediaEntry", current_user) & Permission.accessible_by_user("MediaEntry", @user)
#                          MediaEntry.by_ids(viewable_ids)
#                        end
#                      else
#                        # intersection between public media_entries and somebody viewable media_entries => WRONG!!!
#                        viewable_ids = Permission.accessible_by_user("MediaEntry", @user) & Permission.accessible_by_all("MediaEntry")
#                        MediaEntry.by_ids(viewable_ids)
#                      end
#                    else
#                      if logged_in?
#                        viewable_ids = Permission.accessible_by_user("MediaEntry", current_user)
#                        if params[:not_by_current_user]
#                          # all media_entries I can see but not uploaded by me
#                          MediaEntry.not_by_user(current_user).by_ids(viewable_ids)
#                        elsif request.fullpath =~ /favorites/
#                          MediaEntry.by_ids(viewable_ids & current_user.favorite_ids)
#                        else
#                          # all media_entries I can see
#                          MediaEntry.by_ids(viewable_ids)
#                        end
#                      else
#                        # all public media_entries
#                        ids = Permission.accessible_by_all("MediaEntry")
#                        MediaEntry.by_ids(ids)
#                      end
#                    end
#
#    @media_entries = media_entries.search params[:query],
#                                           { #TODO activate this if you need advanced search# :match_mode => :extended2,
#                                           :page => params[:page], :per_page => params[:per_page].to_i, :retry_stale => true,
#                                           :star => true,
#                                           #temp# :order => (params[:order].blank? ? nil : params[:order]), # OPTIMIZE params[:search][:order]
#                                           :include => :media_file }
#
#    @json = Logic.data_for_page(@media_entries, current_user).to_json

    ########################################################################
    # Approach 2: filtering ids after search

    scope, viewable_ids = if @user
                            ids = if logged_in?
                              Permission.accessible_by_user("MediaEntry", current_user)
                            else
                              Permission.accessible_by_all("MediaEntry")
                            end
                            [MediaEntry.by_user(@user), ids]
                          else
                            if logged_in?
                              ids = Permission.accessible_by_user("MediaEntry", current_user)
                              if params[:not_by_current_user]
                                # all media_entries I can see but not uploaded by me
                                [MediaEntry.not_by_user(current_user), ids]
                              elsif request.fullpath =~ /favorites/
                                [MediaEntry, (ids & current_user.favorite_ids)]
                              else
                                # all media_entries I can see
                                [MediaEntry, ids]
                              end
                            else
                              # all public media_entries
                              ids = Permission.accessible_by_all("MediaEntry")
                              [MediaEntry, ids]
                            end
                          end

    all_ids = scope.search_for_ids params[:query], {:per_page => (2**30), :star => true }
    # all_ids.results[:matches].select {|x| x[:attributes]["class_crc"] == MediaEntry.to_crc32}
    paginated_ids = (all_ids & viewable_ids).paginate(:page => params[:page], :per_page => params[:per_page].to_i)
    @json = Logic.data_for_page2(paginated_ids, current_user).to_json

    ########################################################################

    # OPTIMIZE only used for html and js formats, move to controller helper
    @editable_sets = Media::Set.accessible_by(current_user, :edit)
    
    respond_to do |format|
      format.html
      format.js { render :json => @json }
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

  def image
    # TODO dry => Resource#thumb_base64
    media_file = @media_entry.media_file
    preview = media_file.get_preview(:large)
    file = File.join(THUMBNAIL_STORAGE_DIR, media_file.shard, preview.filename)
    if File.exist?(file)
      output = File.read(file)
      send_data output, :type => preview.content_type, :disposition => 'inline'
    else
      # TODO send alternative output
    end
  end
  
  def map
    meta_data = @media_entry.media_file.meta_data
    @lat = meta_data["GPS:GPSLatitude"]
    @lng = meta_data["GPS:GPSLongitude"]

    respond_to do |format|
      format.html
      format.js { render :layout => false }
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

    respond_to do |format|
      format.html { 
        flash[:notice] = "Der Medieneintrag wurde gelöscht."
        redirect_back_or_default(media_entries_path) 
      }
      format.js { render :json => {:id => @media_entry.id} }
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
  
  def toggle_favorites
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
# BATCH actions

  def remove_multiple
#old 1003#
#    @media_entries.each do |media_entry|
#      @media_set.media_entries.delete(media_entry)
#      media_entry.sphinx_reindex
#    end
    @media_set.media_entries.delete(@media_entries)
    flash[:notice] = "Die Medieneinträge wurden aus dem Set gelöscht."
    redirect_to media_set_url(@media_set)
  end
  
  def edit_multiple
    # custom hash for jQuery json templates
    @info_to_json = @media_entries.map do |me|
      me.attributes.merge!(me.get_basic_info(["uploaded at", "uploaded by", "keywords", "copyright notice", "portrayed object dates"]))
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
    
    redirect_back_or_default(media_entries_path)
  end
  
  def edit_multiple_permissions
    @combined_permissions = Permission.compare(@media_entries)
    @permissions_json = @combined_permissions.to_json

    @media_entries_json = @media_entries.map do |me|
      me.attributes.merge!(me.get_basic_info)
    end.to_json
  end
  
#####################################################

  private

  def authorized?
    conditions = [] # OPTIMIZE
    action = request[:action].to_sym
    case action
      when :new
        action = :create
      when :show, :image, :map
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
      when :edit_multiple, :update_multiple, :edit_multiple_permissions
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

      if not params[:media_entry_id].blank?
        @media_entry =  if @media_set
                          @media_set.media_entries.find(params[:media_entry_id])
                        elsif @user
                          @user.media_entries.find(params[:media_entry_id])
                        # TODO if @user and @media_set ??
                        else
                          MediaEntry.find(params[:media_entry_id])
                        end
      end
  end
  
  def pre_load_for_batch
    params.delete_if {|k,v| v.blank? }
    action = request[:action].to_sym
    
    @media_set = Media::Set.find(params[:media_set_id]) unless params[:media_set_id].blank?
    
     if not params[:media_entry_ids].blank?
        selected_ids = params[:media_entry_ids].split(",").map{|e| e.to_i }
        @media_entries = case action
          when :edit_multiple, :update_multiple
            editable_ids = Permission.accessible_by_user(MediaEntry, current_user, :edit)
            MediaEntry.where(:id => (selected_ids & editable_ids))
          when :edit_multiple_permissions
            manageable_ids = Permission.accessible_by_user(MediaEntry, current_user, :manage)
            MediaEntry.where(:id => (selected_ids & manageable_ids))
          when :remove_multiple
            MediaEntry.where(:id => selected_ids)
        end
     else
       flash[:error] = "Sie haben keine Medieneinträge ausgewählt."
       redirect_to :back
     end
    
  end


end
