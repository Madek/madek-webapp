# -*- encoding : utf-8 -*-
class MediaEntriesController < ApplicationController

  before_filter do
    # TODO test; useful for will_paginate and forwarding links; refactor to application_controller?
    params.delete_if {|k,v| v.blank? }

    if [:edit_multiple, :update_multiple, :remove_multiple].include? request[:action].to_sym
      begin
        if !params[:media_set_id].blank?
          action = case request[:action].to_sym
            when :remove_multiple
              :edit
          end
          @media_set = MediaSet.accessible_by_user(current_user, action).find(params[:media_set_id])
        elsif !params[:media_entry_ids].blank?
          selected_ids = params[:media_entry_ids].split(",").map{|e| e.to_i }
          action = case request[:action].to_sym
            when :edit_multiple, :update_multiple
              :edit
            when :remove_multiple
              :view
          end
          @media_entries = MediaEntry.accessible_by_user(current_user, action).find(selected_ids)
        else
          flash[:error] = "Sie haben keine Medieneinträge ausgewählt."
          redirect_to :back
        end
      rescue
        not_authorized!
      end

    else

      @user = User.find(params[:user_id]) unless params[:user_id].blank?
      @context = MetaContext.find(params[:context_id]) unless params[:context_id].blank?
      @media_set = (@user? @user.media_sets : MediaSet).find(params[:media_set_id]) unless params[:media_set_id].blank? # TODO shallow
  
      unless (params[:media_entry_id] ||= params[:id] || params[:media_entry_ids]).blank?
        action = case request[:action].to_sym
          when :show, :map, :browse, :media_sets
            :view
          when :edit, :update, :edit_tms, :to_snapshot, :destroy
            :edit
        end
  
        begin
          @media_entry =  if @media_set
                            @media_set.media_entries.accessible_by_user(current_user, action).find(params[:media_entry_id])
                          elsif @user
                            @user.media_entries.accessible_by_user(current_user, action).find(params[:media_entry_id])
                          # TODO if @user and @media_set ??
                          else
                            MediaResource.media_entries_or_media_entry_incompletes.accessible_by_user(current_user, action).find(params[:media_entry_id])
                          end
        rescue
          not_authorized!
        end
      end
    end

  end

#####################################################

  ##
  # Get media entries
  # 
  # @url [GET] /media_entries?[arguments]
  # 
  # @argument [accessible_action] string Limit the list of media entries by the accessible action (view is default)
  #   show, browse, abstract, inheritable_contexts, edit, update, add_member, parents, destroy
  # @argument [with] hash Options forwarded to the results which will be inside of the respond 
  # @argument [parent_ids] array An array with parent ids (of MediaSets) which shall be used for scoping the media entries
  #
  # @example_request
  #   {}
  #
  # @example_request
  #   {"parent_ids": [1,5,7], "with": {"media_resource": {"image": {"as": "base64", "size": "small"}}}}
  #
  # @example_request
  #   {"parent_ids": [1,5,7], "with": {"media_resource": {"image": {"size": "medium"}}}}
  #
  # @request_field [String] accessible_action The accessible action the user can perform on a set
  # @request_field [Hash] with Options forwarded to the results which will be inside of the respond
  # @request_field [Hash] with.media_resources Options forwarded to the results of media_resources
  # @request_field [Hash] with.media_resources.image Options requesting an image for the returning media_resources
  # @request_field [Hash] with.media_resources.image.as Request a format of the returning image object (default is a url to the image)  
  # @request_field [Hash] with Options forwarded to the results which will be inside of the respond
  # @request_field [Hash] with Options forwarded to the results which will be inside of the respond
  # @request_field [Hash] parent_ids A list of parent ids which shall be used for scoping the requested media entries
  #
  # @example_response
  #
  # @response_field [Integer] id The id of a set 
  # @response_field [Hash] media_entries Media entries of the set
  # @response_field [Integer] media_entries[].id The id of a media entry
  # @response_field [String] title The title of the media set 
  # @response_field [Hash] author The author of the media set 
  #
  def index(accessible_action = (params[:accessible_action] || :view).to_sym,
            with = params[:with],
            parent_ids = params[:parent_ids] || nil)
    
    respond_to do |format|
      
      format.json {
                
        entries = unless parent_ids.blank?
          MediaSet.where(:id => parent_ids).flat_map do |parent|
            parent.media_entries.accessible_by_user(current_user, accessible_action)
          end.uniq
        else
          MediaEntry.accessible_by_user(current_user, accessible_action)
        end
        
        render :json => entries.as_json(:with => with, :with_thumb => false) # TODO drop with_thum merge with with
      }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json
      format.xml { render :xml=> @media_entry.to_xml(:include => {:meta_data => {:include => :meta_key}} ) }
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
  
  def browse
    # TODO merge with index
    @viewable_ids = MediaEntry.accessible_by_user(current_user).map(&:id)
  end
  
#####################################################
# Authenticated Area

  def edit
  end

  def destroy
    @media_entry.destroy

    respond_to do |format|
      format.html { 
        flash[:notice] = "Der Medieneintrag wurde gelöscht."
        redirect_back_or_default(resources_path) 
      }
      format.json { render :json => {:id => @media_entry.id} }
    end
  end

#####################################################

  def edit_tms
    not_authorized! and return unless current_user.groups.is_member?("Expert")
  end

  def to_snapshot
    not_authorized! and return unless current_user.groups.is_member?("Expert")
    @media_entry.to_snapshot(current_user)
    redirect_to @media_entry
  end

#####################################################

  ##
  # Manage parent media sets from a specific media entry.
  # 
  # @url [POST] /media_entries/media_sets?[arguments]
  # @url [DELETE] /media_entries/media_sets?[arguments]
  # 
  # @argument [parent_media_set_ids] array The ids of the parent media sets to remove/add
  # @argument [media_entry_ids] array The ids of the entries that have to be added to the sets given as "parent_media_set_ids"
  #
  # @example_request
  #   {"parent_media_set_ids": [1,2,3], "media_entry_ids": [5,6,7]}
  #
  # @request_field [Array] media_set_ids The ids of the parent media sets to remove/add  
  #
  # @example_response
  #   [{"id":407},{"id":406}]
  # 
  # @response_field [Integer] id The id of a removed or an added parent set 
  # 
  def media_sets(parent_media_set_ids = params[:parent_media_set_ids])
    parent_media_sets = MediaSet.accessible_by_user(current_user, :edit).where(:id => parent_media_set_ids.map(&:to_i))

    parent_media_sets.each do |media_set|
      if request.post?
        media_set.media_entries.push_uniq @media_entry
      else
        media_set.media_entries.delete(@media_entry)
      end
    end
    
    respond_to do |format|
      #format.html {redirect_to @media_entry}
      format.json { render :json => parent_media_sets.as_json }
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
    @media_set.media_entries.delete(@media_entries)
    flash[:notice] = "Die Medieneinträge wurden aus dem Set gelöscht."
    redirect_to media_set_url(@media_set)
  end
  
  def edit_multiple
    # custom hash for jQuery json templates
    @info_to_json = @media_entries.map do |me|
      me.attributes.merge!(me.get_basic_info(current_user, ["uploaded at", "uploaded by", "keywords", "copyright notice", "portrayed object dates"]))
    end.to_json
  end
  
  def update_multiple
    @media_entries.each do |media_entry|
      if media_entry.update_attributes(params[:resource], current_user)
        flash[:notice] = "Die Änderungen wurden gespeichert." # TODO appending success message and resource reference (id, title)
      else
        flash[:error] = "Die Änderungen wurden nicht gespeichert." # TODO appending success message and resource reference (id, title)
      end
    end
    
    redirect_back_or_default(resources_path)
  end
  
end
