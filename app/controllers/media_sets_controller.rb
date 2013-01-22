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
  
  before_filter lambda{
    @parents_count = @media_set.parent_sets.accessible_by_user(current_user).count
    @can_edit = current_user.authorized?(:edit, @media_set)
  }, :only => [:show, :parents, :inheritable_contexts, :abstract, :vocabulary]

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
  def show(with = params[:with],
           page = params[:page],
           per_page = (params[:per_page] || PER_PAGE.first).to_i)
    respond_to do |format|
      format.html {
        @highlights = @media_set.highlights.accessible_by_user(current_user)
      }
      format.json {
        render json: view_context.json_for(@media_set, with)
      }
    end
  end

  def abstract(min = params[:min].to_i)
    respond_to do |format|
      format.html {@totalChildren = @media_set.child_media_resources.accessible_by_user(current_user).count}
      format.js { render :layout => false }
      format.json { render :json => view_context.hash_for(@media_set.abstract(min, current_user), {:label => true}) }
    end
  end

  def vocabulary
    used_meta_term_ids = @media_set.used_meta_term_ids(current_user)
    @vocabulary = @media_set.individual_contexts.map {|context| view_context.vocabulary(context, used_meta_term_ids) }
    respond_to do |format|
      format.html
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

  def parents(parent_media_set_ids = params[:parent_media_set_ids])  
    respond_to do |format|
      format.html {
        @parents = @media_set.parents.accessible_by_user current_user
      }
    end
  end

  def category
  end
      
end
