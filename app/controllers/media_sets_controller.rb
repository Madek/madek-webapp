# -*- encoding : utf-8 -*-
class MediaSetsController < ApplicationController

  before_filter do
      @user = User.find(params[:user_id]) unless params[:user_id].blank?
      @context = MetaContext.find(params[:context_id]) unless params[:context_id].blank?
      
      unless (params[:media_set_id] ||= params[:id] || params[:media_set_ids]).blank?
        action = case request[:action].to_sym
          when :index, :show, :browse, :abstract, :inheritable_contexts, :parents
            :view
          when :update, :add_member
            :edit
        end

        begin
          @media_set = (@user? @user.media_sets : MediaSet).accessible_by_user(current_user, action).find(params[:media_set_id])
        rescue
          not_authorized!
        end
      end
  end

#####################################################
  
  ################### FIXME this is deprecated !! merge to media_resources#index ###############
  # Get media sets
  # 
  # @resource /media_sets
  #
  # @action GET
  # 
  # @optional [accessible_action] string Limit the list of media sets by the accessible action
  #   show, browse, abstract, inheritable_contexts, edit, update, add_member, parents
  #
  # @optional [with] hash Options forwarded to the results which will be inside of the respond 
  # 
  # @optional [child_ids] array An array with child ids which shall be used for scoping the media sets
  #
  # @example_request
  #   {"accessible_action": "edit", "with": {"media_set": {"media_entries": 1}}}
  #
  # @example_request
  #   {"accessible_action": "edit", "child_ids": [1]}
  #
  # @example_request
  #   {"accessible_action": "edit", "child_ids": [1,2], "with": {"media_set": {"media_entries": 1, "child_sets": 1}} // FIXME {"children": 1}
  #
  # @example_request
  #   {"accessible_action": "edit", "with": {"media_set": {"creator": 1, "created_at": 1, "title": 1}}}
  #
  def index(accessible_action = (params[:accessible_action] || :view).to_sym,
            with = params[:with],
            collection_id = params[:collection_id] || nil,
            child_ids = params[:child_ids] || nil)
    
    respond_to do |format|
      #-# only used for FeaturedSet
      format.html {
        resources = MediaSet.accessible_by_user(current_user)
    
        @media_sets, @my_media_sets, @my_title, @other_title = if @media_set
          # all media_sets I can see, nested within a media set (for now only used with featured sets)
          [resources.where(:id => @media_set.child_media_resources.media_sets), nil, "#{@media_set}", nil]
        elsif @user and @user != current_user
          # all media_sets I can see that have been created by another user
          [resources.by_user(@user), nil, "Sets von %s" % @user, nil]
        else # TODO elsif @user == current_user
          # all media sets I can see that have not been created by me
          other = resources.not_by_user(current_user)
          my = resources.by_user(current_user)
          [other, my, "Meine Sets", "Weitere Sets"]
        end
      }
      format.json {
        child_ids = MediaResource.by_collection(current_user.id, collection_id) unless collection_id.blank?
        media_sets = unless child_ids.blank?
          MediaResource.where(:id => child_ids).flat_map do |child|
            child.parent_sets.accessible_by_user(current_user, accessible_action)
          end.uniq
        else
          MediaSet.accessible_by_user(current_user, accessible_action)
        end
        render json: view_context.hash_for_media_resources_with_pagination(media_sets, true, with).to_json
      }
    end
  end

  ##
  # Get a specific media set:
  # 
  # @resource /media_sets/:id
  #
  # @action GET
  #
  # @required [Integer] id The id of the specific MediaSet.
  #
  # @optional [Hash] with You can use all "with" parameters that are valid for MediaResources.
  # @optional [Hash/Boolean] with[children] Adds the children to the responding MediaSet. You can define either the type (media_set or media_entry) or just include all childrens with true.
  # @optional [Hash/Boolean] with[parents] Adds the parents to the responding MediaSet.
  #
  # @example_request {"id": 1, "with": {"children": true}}
  # @example_request_description Request the MediaSet with id 1 including children of all kinds.
  # @example_response {"id":1, "type":"media_set" "children": [{"id": 3, "type": "media_entry"}, {"id": 4, "type": "media_set"}]}
  # @example_request_description The MediaSet with id 1 is containing a MediaEntry (id: 3) and a MediaSet (id: 4).
  #
  # @example_request {"id": 1, "with": {"parents": true}}
  # @example_request_description Request the MediaSet with id 1 including parents of all kinds.
  # @example_response {"id":1, "type":"media_set" "parents": [{"id": 6, "type": "media_set"}, {"id": 8, "type": "media_set"}]}
  # @example_request_description The MediaSet with id 1 is child of media_set with id 6 and media_set with id 8.
  #
  # @response_field [Integer] id The id of the MediaSet.
  # @response_field [Integer] type The type of the MediaSet (in this case always "media_set").
  # @response_field [Array] children The children of the specific MediaSet.
  # @response_field [Array] parents The parents of the specific MediaSet.
  #
  def show(with = params[:with],
           page = params[:page],
           per_page = (params[:per_page] || PER_PAGE.first).to_i)
    respond_to do |format|
      format.html {
        # TODO this is temporary (similar to media_resources#index), remove it when not needed anymore
        MediaResourceModules::Filter::DEPRECATED_KEYS.each_pair {|k,v| params[k] ||= params.delete(v) if params[v] }
        @filter = params.select {|k,v| MediaResourceModules::Filter::KEYS.include?(k.to_sym) }.delete_if {|k,v| v.blank?}.deep_symbolize_keys

        @parents = @media_set.parent_sets.accessible_by_user(current_user)
      }
      format.json {
        render json: view_context.json_for(@media_set, with)
      }
    end
  end

  def abstract
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def browse
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

#####################
 
  def inheritable_contexts
    @inheritable_contexts = @media_set.inheritable_contexts
    respond_to do |format|
      format.json{render :json => @inheritable_contexts}
    end

  end

#####################################################
# Authenticated Area
# TODO

  ##
  # Create media sets
  # 
  # @url [POST] /media_sets?[arguments]
  # 
  # @argument [media_sets] array Including all media_sets wich have to be created
  #
  # @argument [media_sets][filter][meta_data] array Including meta_data to be filtered, in this case a filter_set will be created
  # @argument [media_sets][filter][search] string The search string to be filtered, in this case a filter_set will be created
  #
  #
  # @example_request
  #   {"media_set": {"meta_data_attributes": [{"meta_key_label":"title", "value": "My Title"}]}}
  #
  # @request_field [Array] media_sets The array of media_sets which have to be created
  #
  # @request_field [Integer] media_sets[x].meta_key_label The label of the meta_key which should be setted on creation
  #
  # @request_field [String] media_sets[x].value The value for the defined meta_key
  #
  # @example_response
  #   [{"id":12574,"title":"My First Set"},{"id":12575,"title":"My Second Set"}]
  #
  # @response_field [Integer] id The id of the created set
  #
  # @response_field [Integer] title The title of the created set
  # 
  def create(attr = params[:media_sets] || params[:media_set],
             filter = params[:filter])
    is_saved = true
    if not attr.blank? and attr.has_key? "0" # CREATE MULTIPLE
      # TODO ?? find_by_id_or_create_by_title
      @media_sets = [] 
      attr.each_pair do |k,v|
        media_set = current_user.media_sets.create
        media_set.update_attributes(v)
        @media_sets << media_set
        is_saved = (is_saved and media_set.save)
      end
    else # CREATE SINGLE
      @media_set = current_user.media_sets.create
      is_saved = @media_set.update_attributes(attr)
    end

    # we are actually creating a filter_set
    unless filter.blank?
      (@media_sets || [@media_set]).each do |media_set|
        media_set.becomes FilterSet
        media_set.update_column(:type, "FilterSet")
        media_set.settings[:filter] = filter.delete_if {|k,v| v.blank?}.deep_symbolize_keys
        media_set.save
      end
    end

    respond_to do |format|
      format.html {
        if is_saved
          redirect_to media_resources_path(:user_id => current_user, :type => "media_sets")
        else
          flash[:notice] = @media_set.errors.full_messages
          redirect_to :back
        end
      }
      format.json {
        if @media_sets
          render json: view_context.hash_for_media_resources_with_pagination(@media_sets, true).to_json, :status => (is_saved ? 200 : 500)
        else
          render json: view_context.json_for(@media_set), :status => (is_saved ? 200 : 500)
        end
      }
    end
  end
  
  def update(individual_context_ids = params[:individual_context_ids],
             filter = params[:filter])
    if individual_context_ids
      individual_context_ids.delete_if &:blank? # NOTE receiving params[:individual_context_ids] even if no checkbox is checked
      @media_set.individual_contexts.clear
      @media_set.individual_contexts = MetaContext.find(individual_context_ids)
      @media_set.save
    end

    # we are actually updating a filter_set
    if @media_set.is_a?(FilterSet) and not filter.blank?
      @media_set.settings[:filter] = filter.delete_if {|k,v| v.blank?}.deep_symbolize_keys
      @media_set.save
    end

    respond_to do |format|
      format.html { redirect_to @media_set }
      format.json { render :json => {:id => @media_set.id}, :status => :ok }
    end
  end

#####################################################

  def settings
    if request.post?
      begin
        @media_set.settings[:layout] = params[:layout].to_sym unless params[:layout].nil?
        @media_set.settings[:sorting] = params[:sorting].to_sym unless params[:sorting].nil?
        @media_set.save
        render :nothing => true, :status => :ok
      rescue
        render :nothing => true, :status => :bad_request
      end
    end
  end

#####################################################

  def add_member
    if @media_set
      new_members = 0 #temp#
      #raise params[:media_entry_ids].inspect
      if params[:media_entry_ids] && !(params[:media_entry_ids] == "null") #check for blank submission from select
        ids = params[:media_entry_ids].is_a?(String) ? params[:media_entry_ids].split(",") : params[:media_entry_ids]
        media_entries = MediaEntry.find(ids)
        new_members = @media_set.child_media_resources << media_entries
      end
      flash[:notice] = if new_members > 1
         "#{new_members} neue Medieneinträge wurden dem Set #{@media_set.title} hinzugefügt" 
      elsif new_members == 1
        "Ein neuer Medieneintrag wurde dem Set #{@media_set.title} hinzugefügt" 
      else
        "Es wurden keine neuen Medieneinträge hinzugefügt."
      end
      respond_to do |format|
        format.html { 
          unless params[:media_entry_ids] == "null" # check for blank submission of batch edit form.
            redirect_to(@media_set) 
          else
            flash[:error] = "Keine Medieneinträge ausgewählt"
            redirect_to @media_set
          end
          } # OPTIMIZE
      end
    else
      @media_sets = @user.media_sets
    end
  end

  ##
  # Manage parent media sets from a specific media set.
  # 
  # @url [POST] /media_sets/parents?[arguments]
  # @url [DELETE] /media_sets/parents?[arguments]
  # 
  # @argument [parent_media_set_ids] array The ids of the parent media sets to remove/add
  #
  # @example_request
  #   {"parent_media_set_ids": [1,2,3], "media_set_ids": [5]}
  #   {"parent_media_set_ids": [1,2,3], "media_set_ids": [5,6]}
  #
  # @request_field [Array] parent_media_set_ids The ids of the parent media sets to remove/add  
  # @request_field [Array] media_set_ids The ids of the media sets that have to be added to the parent sets (given in "parent_media_set_ids")   
  #
  # @example_response
  #   [{"id":407, "parent_ids":[1,2,3]}]
  # 
  # @response_field [Hash] media_set The media set changed
  # @response_field [Integer] media_set.id The id of the changed media set
  # @response_field [Array] media_set.parent_ids The ids of the parents of the changes media set 
  # 
  def parents(parent_media_set_ids = params[:parent_media_set_ids])
    parent_media_sets = MediaSet.accessible_by_user(current_user, :edit).where(:id => parent_media_set_ids.map(&:to_i))
    child_media_sets = Array(@media_set)
    
    child_media_sets.each do |media_set|
      if request.post?
        parent_media_sets.each do |parent_media_set|
          media_set.parent_sets << parent_media_set
        end
      elsif request.delete?
        parent_media_sets.each do |parent_media_set|
          media_set.parent_sets.delete(parent_media_set)
        end
      end
    end
    
    respond_to do |format|
      format.json {
        render json: view_context.json_for(child_media_sets, {:parents => true})
      }
    end
  end

  # TODO merge to index ??
  def graph
    respond_to do |format|
      format.html {
        # TODO this is temporary (similar to media_resources#index), remove it when not needed anymore
        MediaResourceModules::Filter::DEPRECATED_KEYS.each_pair {|k,v| params[k] ||= params.delete(v) if params[v] }
        @filter = params.select {|k,v| MediaResourceModules::Filter::KEYS.include?(k.to_sym) }.delete_if {|k,v| v.blank?}.deep_symbolize_keys

        @filter[:type] = "media_sets" # checked in current_settings view helper 
      }
      format.json {
        #media_sets = MediaSet.accessible_by_user(current_user).relative_top_level
        media_sets = current_user.media_sets #.relative_top_level
        render json: view_context.hash_for_graph(media_sets).to_json
      }
    end
  end

  def categories
  end
      
end
