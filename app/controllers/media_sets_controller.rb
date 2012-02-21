# -*- encoding : utf-8 -*-
class MediaSetsController < ApplicationController

  before_filter do
      @user = User.find(params[:user_id]) unless params[:user_id].blank?
      @context = MetaContext.find(params[:context_id]) unless params[:context_id].blank?
      
      unless (params[:media_set_id] ||= params[:id] ||= params[:media_set_ids]).blank?
        action = case request[:action].to_sym
          when :show, :browse, :abstract, :inheritable_contexts, :parents
            :view
          when :edit, :update, :add_member, :destroy
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

  ##
  # Get media sets
  # 
  # @url [GET] /media_sets?[arguments]
  # 
  # @argument [accessible_action] string Limit the list of media sets by the accessible action
  #   show, browse, abstract, inheritable_contexts, edit, update, add_member, parents, destroy
  #
  # @argument [with] hash Options forwarded to the results which will be inside of the respond 
  # 
  # @argument [child_ids] array An array with child ids which shall be used for scoping the media sets
  #
  # @example_request
  #   {"accessible_action": "edit", "with": {"media_set": {"media_entries": 1}}}
  #
  # @example_request
  #   {"accessible_action": "edit", "child_ids": [1]}
  #
  # @example_request
  #   {"accessible_action": "edit", "child_ids": [1,2], "with": {"media_set": {"media_entries": 1, "child_sets": 1}}
  #
  # @example_request
  #   {"accessible_action": "edit", "with": {"media_set": {"creator": 1, "created_at": 1, "title": 1}}}
  #
  # @request_field [String] accessible_action The accessible action the user can perform on a set
  # @request_field [Hash] with Options forwarded to the results which will be inside of the respond
  # @request_field [Hash] with.set Options forwarded to all resulting models from type set
  # @request_field [Hash] with.set.media_entries When this hash of options is setted, it forces all result sets
  #   to include their media_entries forwarding the options. When "media_entries" is just setted to 1, then 
  #   they are include but without forwarding any options.
  # @request_field [Integer] with.set.title When this hash of options is setted, provide the set title in the results
  # @request_field [Array] child_ids A list of childs which shall be used for scoping the result of media sets
  #
  # @example_response
  #   [{"id":422, "media_entries": [{"id":2}, {"id":3}]}, {"id":423, "media_entries": [{"id":1}, {"id":4}]}]
  #
  # @example_response
  #   [{"id":422, "title": "My Private Set", "creator": {"id": 142, "name": "Max Muster"}}]
  #
  # @response_field [Integer] id The id of a set 
  # @response_field [Hash] media_entries Media entries of the set
  # @response_field [Integer] media_entries[].id The id of a media entry
  # @response_field [String] title The title of the media set 
  # @response_field [Hash] author The author of the media set 
  #
  def index(accessible_action = (params[:accessible_action] || :view).to_sym,
            with = params[:with],
            child_ids = params[:child_ids] || nil)

    respond_to do |format|
      #-# only used for FeaturedSet
      format.html {
        resources = MediaSet.accessible_by_user(current_user)
    
        @media_sets, @my_media_sets, @my_title, @other_title = if @media_set
          # all media_sets I can see, nested within a media set (for now only used with featured sets)
          [resources.where(:id => @media_set.child_sets), nil, "#{@media_set}", nil]
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
      
      format.js {
        
        sets = unless child_ids.blank?
          MediaResource.where(:id => child_ids).flat_map do |child|
            child.parent_sets.accessible_by_user(current_user, accessible_action)
          end.uniq
        else
          MediaSet.accessible_by_user(current_user, accessible_action)
        end

        render :json => sets.as_json(:current_user => current_user, :with => with, :with_thumb => false) # TODO drop with_thum merge with with
      }
    end
  end

  ##
  # Get a specific media set
  # 
  # @url [GET] /media_sets/:id?[arguments]
  # 
  # @argument [id] integer The id of the specific media_set 
  # 
  # @argument [with] hash Options forwarded to the results which will be inside of the respond 
  # 
  # @example_request
  #   {"id": 34, "with": {"media_set": {"media_entries": 1}}}
  #
  # @request_field [Integer] id The id of the requested media_set
  # @request_field [Hash] with Options forwarded to the results which will be inside of the respond
  # @request_field [Hash] with.set Options forwarded to all resulting models from type set
  # @request_field [Hash] with.set.media_entries When this hash of options is setted, it forces all result sets
  #   to include their media_entries forwarding the options. When "media_entries" is just setted to 1, then 
  #   they are include but without forwarding any options.
  #
  # @example_response
  #   [{"id":422, "media_entries": [{"id":2}, {"id":3}]}, {"id":423, "media_entries": [{"id":1}, {"id":4}]}]
  #
  # @response_field [Integer] id The id of a set 
  # @response_field [Hash] media_entries Media entries of the set
  # @response_field [Integer] media_entries[].id The id of a media entry
  #
  def show(thumb = params[:thumb], with = params[:with])
    respond_to do |format|
      format.html {
        params[:per_page] ||= PER_PAGE.first
        paginate_options = {:page => params[:page], :per_page => params[:per_page].to_i}
        resources = MediaResource.accessible_by_user(current_user).order("media_resources.updated_at DESC").by_media_set(@media_set).paginate(paginate_options)
        with_thumb = true
        
        @can_edit_set = current_user.authorized?(:edit, @media_set)
        @parents = @media_set.parent_sets.as_json(:user => current_user)
        @media_entries = { :pagination => { :current_page => resources.current_page,
                                            :per_page => resources.per_page,
                                            :total_entries => resources.total_entries,
                                            :total_pages => resources.total_pages },
                           :entries => resources.as_json(:user => current_user, :with_thumb => with_thumb) } 
      }
      
      format.json {
        render :json => @media_set.as_json(:with => with, :current_user =>current_user)
      }
      
      # TODO drop js and use json only, this is currently only used for the inview-pagination
      format.js {
        # OPTIMIZE this is a quick-fix for the inview-pagination
        if params[:page]
          params[:per_page] ||= PER_PAGE.first
          paginate_options = {:page => params[:page], :per_page => params[:per_page].to_i}
          resources = MediaResource.accessible_by_user(current_user).order("media_resources.updated_at DESC").by_media_set(@media_set).paginate(paginate_options)
          with_thumb = true
          json = { :pagination => { :current_page => resources.current_page,
                                    :per_page => resources.per_page,
                                    :total_entries => resources.total_entries,
                                    :total_pages => resources.total_pages },
                   :entries => resources.as_json(:user => current_user, :with_thumb => with_thumb) } 
        end
        render :json => json
      }

      # TODO disable the above and enable blow for json emplated rendering 
      # @media_entries = @media_set.media_entries.accessible_by_user(current_user)
      # @media_set = MediaSet.find params[:id]
      # format.json 

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
      #format.js { render :json => @inheritable_contexts}
      #format.html{render :text => "Use JSON", :status => 406}
      #format.html{render :text => "Use JSON"}
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
  # @example_request
  #   {"media_sets": [{"meta_key_label":"title", "value": "My Title"}, {"meta_key_label":"title", "value": "My Title"}]}
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
  def create(attr = params[:media_sets] || params[:media_set])
    
    is_saved = true
    if not attr.blank? and attr.has_key? "0" # CREATE MULTIPLE
      # TODO ?? find_by_id_or_create_by_title
      @media_sets = [] 
      attr.each_pair do |k,v|
        media_set = current_user.media_sets.build(v)
        @media_sets << media_set
        is_saved = (is_saved and media_set.save)
      end
    else # CREATE SINGLE
      @media_set = current_user.media_sets.build(attr)
      is_saved = @media_set.save
    end

    respond_to do |format|
      format.html {
        if is_saved
          redirect_to user_resources_path(current_user, :type => "media_sets")
        else
          flash[:notice] = @media_set.errors.full_messages
          redirect_to :back
        end
      }
      format.js {
        r = @media_sets ? @media_sets : @media_set
        render :json => r.as_json(:user => current_user), :status => (is_saved ? 200 : 500)
      }
    end
  end
  
  def edit
  end

  def update
    if params[:individual_context_ids]
      params[:individual_context_ids].delete_if &:blank? # NOTE receiving params[:individual_context_ids] even if no checkbox is checked
      @media_set.individual_contexts.clear
      @media_set.individual_contexts = MetaContext.find(params[:individual_context_ids])
      @media_set.save
    end
    
    redirect_to @media_set
  end

  def destroy
    # TODO ACL
    if params[:media_set_id]
      @media_set.destroy
    end
    respond_to do |format|
      format.html { redirect_to user_resources_path(current_user, :type => "media_sets") }
      format.js { render :json => {:id => @media_set.id} }
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
        new_members = @media_set.media_entries.push_uniq(media_entries)
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
#temp3#
#        format.js { 
#          render :update do |page|
#            page.replace_html 'flash', flash_content
#          end
#        }
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
      #format.html { redirect_to @media_set }
      format.js { 
        render :json => child_media_sets.as_json(:user => current_user, :methods => :parent_ids) 
      }
    end
  end
  
end
