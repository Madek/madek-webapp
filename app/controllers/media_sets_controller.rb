# -*- encoding : utf-8 -*-
class MediaSetsController < ApplicationController


  before_filter :pre_load
  before_filter :authorized?, :except => [:index, :create]

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
  # @argument [children] array An array with child objects {:id, :type} which shall be used for scoping the media sets
  #
  # @argument [user] hash An object {:id} which shall be used for scoping the media sets for a specific user
  #
  # @example_request
  #   {"accessible_action": "edit", "with": {"set": {"media_entries": 1}}}
  #
  # @example_request
  #   {"accessible_action": "edit", "child_ids": [1]}
  #
  # @example_request
  #   {"accessible_action": "edit", "child_ids": [1,2], "with": {"set": {"media_entries": 1, "child_sets": 1}}
  #
  # @example_request
  #   {"accessible_action": "edit", "with": {"set": {"creator": 1, "created_at": 1, "title": 1}}}
  #
  # @request_field [String] accessible_action The accessible action the user can perform on a set
  # @request_field [Hash] with Options forwarded to the results which will be inside of the respond
  # @request_field [Hash] with.set Options forwarded to all resulting models from type set
  # @request_field [Hash] with.set.media_entries When this hash of options is setted, it forces all result sets
  #   to include their media_entries forwarding the options. When "media_entries" is just setted to 1, then 
  #   they are include but without forwarding any options.
  # @request_field [Integer] with.set.title When this hash of options is setted, provide the set title in the results
  # @request_field [Hash] child A child object which shall be used for scoping the media sets
  # @request_field [Hash] user A user object which shall be used for scoping the media sets for a specific user
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
  def index(accessible_action = params[:accessible_action] || :view,
            with = params[:with], child_ids = params[:child_ids] || nil)

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
          [other.media_sets, my.media_sets, "Meine Sets", "Weitere Sets"]
        end
      }
      
      format.js {
                
        sets = unless child_ids.blank?
          MediaResource.where(:id => child_ids).flat_map do |child|
            child.parent_sets.accessible_by_user(current_user, accessible_action.to_sym)
          end.uniq
        else
          MediaSet.accessible_by_user(current_user, accessible_action.to_sym)
        end

        render :json => sets.as_json(:with => with, :with_thumb => false) # TODO drop with_thum merge with with
      }
    end
  end

  # API #
  # get nested media_entries:
  # GET "/media_sets/:id.js"
  def show( options_for_media_entries = params[:options_for_media_entries],
            thumb = params[:thumb])
            
    params[:per_page] ||= PER_PAGE.first

    paginate_options = {:page => params[:page], :per_page => params[:per_page].to_i}
    resources = MediaResource.accessible_by_user(current_user).by_media_set(@media_set).paginate(paginate_options)
    
    @can_edit_set = Permissions.authorized?(current_user, :edit, @media_set)
    @parents = @media_set.parent_sets.as_json(:user => current_user)
    
    respond_to do |format|
      format.html {
        with_thumb = true
        @media_entries = { :pagination => { :current_page => resources.current_page,
                                            :per_page => resources.per_page,
                                            :total_entries => resources.total_entries,
                                            :total_pages => resources.total_pages },
                           :entries => resources.as_json(:user => current_user, :with_thumb => with_thumb) } 
      }
      format.js {
        
        # OPTIMIZE this is a quick-fix for the inview-pagination
        if params[:page]
          with_thumb = true
          json = { :pagination => { :current_page => resources.current_page,
                                    :per_page => resources.per_page,
                                    :total_entries => resources.total_entries,
                                    :total_pages => resources.total_pages },
                   :entries => resources.as_json(:user => current_user, :with_thumb => with_thumb) } 
        else
          #FE# render :json => @media_set.as_json(:user => current_user)
          json = {:id => @media_set.id, :title => @media_set.title}
          if options_for_media_entries and options_for_media_entries.is_a? Hash
            options_for_media_entries.reverse_merge!(:only => :id, :methods => :title, :user => current_user)
            json.merge!(:entries => resources.as_json(options_for_media_entries))
          end
        end
        
        render :json => json
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
  def create(attr = params[:media_sets] ||= params[:media_set])
    
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

#####################################################

  private

  def authorized?
    action = request[:action].to_sym
    case action
#      when :new
#        action = :create
      when :show, :browse, :abstract, :inheritable_contexts, :parents
        action = :view
      when :edit, :update, :add_member
        action = :edit
      when :destroy
        action = :edit # TODO :delete
    end
    if @media_set
      resource = @media_set
      not_authorized! unless Permissions.authorized?(current_user, action, resource) # TODO super ??
    else
      flash[:error] = "Kein Medienset ausgewählt."
      redirect_to :back
    end
  end

  def pre_load
      @user = User.find(params[:user_id]) unless params[:user_id].blank?
      @context = MetaContext.find(params[:context_id]) unless params[:context_id].blank?
      
      params[:media_set_id] ||= params[:id] ||= params[:media_set_ids]
      @media_set = (@user? @user.media_sets : MediaSet).find(params[:media_set_id]) unless params[:media_set_id].blank?
  end

end
