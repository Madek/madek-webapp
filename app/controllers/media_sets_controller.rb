# -*- encoding : utf-8 -*-
class MediaSetsController < ApplicationController

  before_filter :pre_load
  before_filter :authorized?, :except => [:index, :create]

  # API #
  # GET "/media_sets.js", {accessible_action: "edit"}
  def index(accessible_action = params[:accessible_action] || :view)
    respond_to do |format|
      #-# only used for FeaturedSet
      format.html {
        resources = MediaResource.accessible_by_user(current_user).media_sets
    
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
          if params[:type] == "projects"
            [other.projects, my.projects, "Meine Projekte", "Weitere Projekte"]
          else
            [other.sets, my.sets, "Meine Sets", "Weitere Sets"]
          end
        end
      }
      format.js {
        resources = MediaResource.accessible_by_user(current_user, accessible_action.to_sym).media_sets
        render :json => resources.as_json(:user => current_user, :with_thumb => false)
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
    
    @can_edit_set = Permission.authorized?(current_user, :edit, @media_set)
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
        #FE# render :json => @media_set.as_json(:user => current_user)
        json = {:id => @media_set.id, :title => @media_set.title}

        if options_for_media_entries and options_for_media_entries.is_a? Hash
          options_for_media_entries.reverse_merge!(:only => :id, :methods => :title, :user => current_user)
          json.merge!(:entries => resources.as_json(options_for_media_entries))
        end
        render :json => json
      }
    end
  end

  # TODO only for media_project
  def abstract
    @_media_entry_ids = MediaResource.accessible_by_user(current_user).media_entries.by_media_set(@media_set).map(&:id)
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  # TODO only for media_project
  def browse
    @project = @media_set
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

#####################################################
# Authenticated Area
# TODO

  # API #
  # POST "/media_sets", {media_set: {meta_data_attributes: {0 => {meta_key_id: 3, value: "Set title"}}} }
  def create(attr = params[:media_set])
    # TODO ?? find_by_id_or_create_by_title
    @media_set = current_user.media_sets.build(attr)
    is_saved = @media_set.save

    respond_to do |format|
      format.html {
        if is_saved
          #temp# flash[:notice] = "Media::Set successful created"
          redirect_to user_resources_path(current_user, :type => "sets")
        else
          flash[:notice] = @media_set.errors.full_messages
          redirect_to :back
        end
      }
      format.js {
        render :json => @media_set.as_json(:user => current_user), :status => (is_saved ? 200 : 500)
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
      format.html { redirect_to user_resources_path(current_user, :type => "sets") }
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
         "#{new_members} neue Medieneinträge wurden dem Set/Projekt #{@media_set.title} hinzugefügt" 
      elsif new_members == 1
        "Ein neuer Medieneintrag wurde dem Set/Projekt #{@media_set.title} hinzugefügt" 
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

  # TODO merge with media_entries_controller#media_sets ?? OR merge to parents using the inverse nesting ??
  # API #
  # POST "/media_sets/:id/parents", {media_set_ids: [1, 2, 3, "My new parent set"] }
  # DELETE "/media_sets/:id/parents", {media_set_ids: [1, 2, 3] }
  def parents(media_set_ids = params[:media_set_ids])
    if request.post?
      Media::Set.find_by_id_or_create_by_title(media_set_ids, current_user).each do |media_set|
        next unless Permission.authorized?(current_user, :edit, media_set) # (Media::Set ACL!)
        @media_set.parents << media_set
      end
    elsif request.delete?
      @media_set.parents.delete(Media::Set.find(media_set_ids))
    end
    
    respond_to do |format|
      format.html { redirect_to @media_set }
      format.js { render :json => @media_set.as_json(:user => current_user, :methods => :parent_ids) }
    end
  end

#####################################################

  private

  def authorized?
    action = request[:action].to_sym
    case action
#      when :new
#        action = :create
      when :show, :browse, :abstract, :parents
        action = :view
      when :edit, :update, :add_member
        action = :edit
      when :destroy
        action = :edit # TODO :delete
    end
    if @media_set
      resource = @media_set
      not_authorized! unless Permission.authorized?(current_user, action, resource) # TODO super ??
    else
      flash[:error] = "Kein Medienset ausgewählt."
      redirect_to :back
    end
  end

  def pre_load
      params[:media_set_id] ||= params[:id]
      @user = User.find(params[:user_id]) unless params[:user_id].blank?
      @media_set = (@user? @user.media_sets : Media::Set).find(params[:media_set_id]) unless params[:media_set_id].blank? # TODO shallow
      @context = MetaContext.find(params[:context_id]) unless params[:context_id].blank?
  end

end
