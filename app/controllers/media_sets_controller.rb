# -*- encoding : utf-8 -*-
class MediaSetsController < ApplicationController

  def check_and_initialize_for_view
    @media_set = MediaSet.find(params[:id])
    not_authorized! unless current_user.authorized?(:view,@media_set)
    @parents_count = @media_set.parent_sets.accessible_by_user(current_user,:view).count
    @can_edit = current_user.authorized?(:edit, @media_set)
  end

  def check_and_initialize_for_edit
    @media_set = MediaSet.find(params[:id])
    not_authorized! unless current_user.authorized?(:edit,@media_set)
  end

#####################################################

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
  def show
    check_and_initialize_for_view

    with = params[:with]
    page = params[:page]
    per_page = (params[:per_page] || PER_PAGE.first).to_i

    respond_to do |format|
      format.html do
        if @media_set.is_a? FilterSet
          @filter_set = @media_set
          render "filter_sets/show"
        else
          @highlights = @media_set.highlights.accessible_by_user(current_user,:view)
          render :show
        end
      end
      format.json { render json: view_context.json_for(@media_set, with) }
    end
  end

  def abstract
    check_and_initialize_for_view

    respond_to do |format|
      format.html {@totalChildren = @media_set.child_media_resources.accessible_by_user(current_user,:view).count}
      format.json { render :json => view_context.hash_for(@media_set.abstract(params[:min].to_i, current_user), {:label => true}) }
    end
  end

  def vocabulary
    check_and_initialize_for_view
    used_meta_term_ids = @media_set.used_meta_term_ids(current_user)
    @vocabulary = @media_set.individual_contexts.map {|context| view_context.vocabulary(context, used_meta_term_ids) }
    respond_to do |format|
      format.html
    end
  end

  def browse
    check_and_initialize_for_view
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

#####################
 
  def inheritable_contexts
    check_and_initialize_for_view 
    @inheritable_contexts = @media_set.inheritable_contexts
    respond_to do |format|
      format.html
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
  def create
    
    attr = params[:media_sets] || params[:media_set]
    filter = params[:filter]
    is_saved = true

    if not attr.blank? and attr.has_key? "0" # CREATE MULTIPLE
      @media_sets = [] 
      attr.each_pair do |k,v|
        media_set = current_user.media_sets.create
        media_set.update_attributes(v)
        media_set.set_meta_data v.slice("meta_data_attributes")
        media_set.update_attributes! v.except("meta_data_attributes")
        @media_sets << media_set
        is_saved = (is_saved and media_set.save)
      end
    else # CREATE SINGLE
      @media_set = current_user.media_sets.create
      @media_set.set_meta_data attr.slice("meta_data_attributes")
      @media_set.update_attributes! attr.except("meta_data_attributes")
      is_saved = @media_set.save
    end

    respond_to do |format|
      format.html do
        if is_saved
          redirect_to media_resources_path(:user_id => current_user, :type => "media_sets")
        else
          flash[:notice] = @media_set.errors.full_messages
          redirect_to :back
        end
      end
      format.json do
        if @media_sets
          render json: view_context.hash_for_media_resources_with_pagination(@media_sets, true).to_json, :status => (is_saved ? 200 : 500)
        else
          render json: view_context.json_for(@media_set), :status => (is_saved ? 200 : 500)
        end
      end
    end
  end
  
  def update
    check_and_initialize_for_edit
    @media_set.individual_contexts=  
      MetaContext.where(name: (params[:individual_context_names] || []))
    redirect_to @media_set 
  end

#####################################################

  def settings
    check_and_initialize_for_edit
    begin
      @media_set.settings[:layout] = params[:layout].to_sym unless params[:layout].nil?
      @media_set.settings[:sorting] = params[:sorting].to_sym unless params[:sorting].nil?
      @media_set.save
      render :nothing => true, :status => :ok
    rescue
      render :nothing => true, :status => :bad_request
    end
  end



  def parents(parent_media_set_ids = params[:parent_media_set_ids])  
    respond_to do |format|
      format.html { @parents = @media_set.parents.accessible_by_user(current_user,:view) }
    end
  end

  def category
  end



end
