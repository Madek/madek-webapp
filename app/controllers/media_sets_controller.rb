# -*- encoding : utf-8 -*-
class MediaSetsController < ApplicationController

  before_filter :pre_load
  before_filter :authorized?, :only => [:show, :edit, :update, :destroy, :add_member] # TODO :except => :index OR check for :index too ??
  after_filter :store_location, :only => [:show]
  
  def index
    ids = current_user.accessible_resource_ids(:view, "Media::Set")

    @media_sets, @my_media_sets, @index_title = if @media_set
      # all media_sets I can see, nested within a media set (for now only used with featured sets)
      [@media_set.children.where(:id => ids), nil, "#{@media_set}"]
    elsif @user and @user != current_user
      # all media_sets I can see that have been created by another user
      [@user.media_sets.where(:id => ids), nil, "Sets von %s" % @user]
    else # TODO elsif @user == current_user
      # all media sets I can see that have not been created by me
      [Media::Set.where(:id => ids).where("user_id != ?", current_user), current_user.media_sets.where(:id => ids), "Meine Sets"]
    # else
      # TODO
    end

    respond_to do |format|
      format.html
    end
  end

  def show
    viewable_ids = current_user.accessible_resource_ids

    #old# ids = @media_set.media_entries.where(:id => viewable_ids).select(:id).map(&:id) # doesn't work: @media_set.media_entry_ids.where(:id => viewable_ids)
    #old# @media_entry_ids = ids.paginate(:page => params[:page], :per_page => PER_PAGE.first)
    @media_entry_ids = (@media_set.media_entry_ids & viewable_ids).paginate(:page => params[:page], :per_page => PER_PAGE.first)
    @json = Logic.data_for_page(@media_entry_ids, current_user).to_json

    @editable_sets = Media::Set.accessible_by(current_user, :edit)
    @can_edit_set = @editable_sets.include?(@media_set)

    respond_to do |format|
      format.html
      format.js { render :json => @json }
    end
  end

#####################################################
# Authenticated Area
# TODO

  def create
    # OPTIMIZE just preventing double delta indexing, because meta_data need resource_id
    Media::Set.suspended_delta do
      @media_set = current_user.media_sets.create # OPTIMIZE validates_presence_of title
      if @media_set.update_attributes(params[:media_set]) # TODO ?? find_by_id_or_create_by_title
        #temp# flash[:notice] = "Media::Set successful created"
        redirect_to user_media_sets_path(current_user)
      else
        flash[:notice] = @media_set.errors.full_messages
        redirect_to :back
      end
    end
  end

  # TODO merge to Permissions#edit_multiple
  def edit
    permissions = Permission.cached_permissions_by(@media_set)
    keys = Permission::ACTIONS
    @permissions_json = {}
    
    permissions.group_by {|p| p.subject_type }.collect do |type, type_permissions|
      unless type.nil?
        @permissions_json[type] = type_permissions.map do |p|
          h = {:id => p.subject.id, :name => p.subject.to_s, :type => type}
          keys.each {|key| h[key] = p.actions[key] } #1504#
          h
        end
      else
        p = type_permissions.first
        @permissions_json["public"] = begin
          h = {:name => "Öffentlich", :type => 'nil'}
          keys.each {|key| h[key] = p.actions[key] } #1504#
          h
        end
      end
    end
    @permissions_json = @permissions_json.to_json
  end

 def destroy
   # TODO ACL
   if params[:media_set_id]
     @media_set.destroy
   end
    respond_to do |format|
      format.html { redirect_to user_media_sets_path(current_user) }
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
        "Ein neuer Medieneintrag wurden dem Set #{@media_set.title} hinzugefügt" 
      else
        "Es wurden keine neuen Medieneinträge hinzugefügt."
      end
      respond_to do |format|
        format.html { 
          unless params[:media_entry_ids] == "null" # check for blank submission of batch edit form.
            redirect_to(@media_set) 
          else
            flash[:error] = "Keine Medieneinträge ausgewählt."
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

#####################################################

  private

  def authorized?
    action = request[:action].to_sym
    case action
#      when :new
#        action = :create
      when :show
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
