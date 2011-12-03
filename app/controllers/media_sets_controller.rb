# -*- encoding : utf-8 -*-
class MediaSetsController < ApplicationController

  before_filter :pre_load
  before_filter :authorized?, :except => [:index, :create]

  #-# only used for FeaturedSet
  def index
    resources = MediaResource.accessible_by_user(current_user).media_sets

    @media_sets, @my_media_sets, @my_title, @other_title = if @media_set
      # all media_sets I can see, nested within a media set (for now only used with featured sets)
      [resources.where(:id => @media_set.children), nil, "#{@media_set}", nil]
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

    #-# @_media_set_ids = (Array(@media_sets) + Array(@my_media_sets)).map(&:id)

    respond_to do |format|
      format.html
    end
  end

  def show
    params[:per_page] ||= PER_PAGE.first

    paginate_options = {:page => params[:page], :per_page => params[:per_page].to_i}
    resources = MediaResource.accessible_by_user(current_user).by_media_set(@media_set).paginate(paginate_options)

    @media_entries = { :pagination => { :current_page => resources.current_page,
                                        :per_page => resources.per_page,
                                        :total_entries => resources.total_entries,
                                        :total_pages => resources.total_pages },
                       :entries => resources.as_json(:user => current_user) } 

    @can_edit_set = Permission.authorized?(current_user, :edit, @media_set)
    
    @parents = @media_set.parents.as_json(:user => current_user)
    
    respond_to do |format|
      format.html
      format.js { render :json => @media_entries.to_json }
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

  def create
    # TODO ?? find_by_id_or_create_by_title
    @media_set = current_user.media_sets.build(params[:media_set])
    if @media_set.save
      #temp# flash[:notice] = "Media::Set successful created"
      redirect_to user_resources_path(current_user, :type => "sets")
    else
      flash[:notice] = @media_set.errors.full_messages
      redirect_to :back
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

  # TODO merge with media_entries_controller#media_sets ?? OR merge to parent using the inverse nesting ??
  def parent
    if request.post?
      Media::Set.find_by_id_or_create_by_title(params[:media_set_ids], current_user).each do |media_set|
        next unless Permission.authorized?(current_user, :edit, media_set) # (Media::Set ACL!)
        media_set.children << @media_set
      end
      redirect_to @media_set
    elsif request.delete?
      # TODO
    end
  end

#####################################################

  private

  def authorized?
    action = request[:action].to_sym
    case action
#      when :new
#        action = :create
      when :show, :browse, :abstract, :parent
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
