# -*- encoding : utf-8 -*-
class MediaSetsController < ApplicationController

  before_filter :pre_load
  before_filter :authorized?, :only => [:show, :edit, :update, :destroy, :add_member] # TODO :except => :index OR check for :index too ??

  def index
    ids = Permission.accessible_by_user("Media::Set", current_user)

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
      #old# ?????
      #format.js {
      #  @media_sets = @media_sets.joins(:meta_data).where(:meta_data => {:meta_key_id => MetaKey.find_by_label("title"), :value => params[:tag]}) if params[:tag]
      #  render :json => @media_sets.map {|x| {:caption => x.to_s, :value => x.id} }
      #}
    end
  end

  def show
    #new# theme "madek11"
    viewable_ids = Permission.accessible_by_user("MediaEntry", current_user)
    @editable_ids = Permission.accessible_by_user("MediaEntry", current_user, :edit)
    editable_set_ids = Permission.accessible_by_user("Media::Set", current_user, :edit)
    per_page = 16 #test# 2
    
    #ASK Franco#: Sphinx reindexing doesn't work when we remove media_entries from a set. Need to revert to active record #
    # @media_entries = MediaEntry.search :with => {:media_set_ids => @media_set.id, :sphinx_internal_id => viewable_ids}, :page => params[:page], :per_page => per_page, :retry_stale => true
    @media_entries =  MediaEntry.joins(:media_sets).where("media_sets.id = ?", @media_set.id).where(:id => viewable_ids)
    
    # for task bar
    @can_edit = editable_set_ids.include?(@media_set.id)
    @editable_in_set = @editable_ids && @media_entries.all.map(&:id)
    @editable_sets = Media::Set.where("id IN (?) AND id <> ?", editable_set_ids, @media_set.id)
    
    @info_to_json = @media_entries.all.map do |me|
      basic = me.attributes.merge!("thumb_base64" => me.thumb_base64(:x_small), "title" => me.meta_data.get_value_for("title"))
      css_class = "thumb_mini"
      css_class += " edit" if @editable_ids.include?(me.id)
      css_class += " edit_set" if @can_edit
      basic["css_class"] = css_class
      basic
    end.to_json
    
    @media_entries = @media_entries.paginate(:page => params[:page], :per_page => per_page)
    
    #2001# @media_entries = @media_set.media_entries.select {|media_entry| Permission.authorized?(current_user, :view, media_entry)}
    #2001# @disabled_paginator = true # OPTIMIZE

    
    respond_to do |format|
      format.html
      format.js { render :partial => "/media_entries/index" }
    end
  end

#####################################################
# Authenticated Area
# TODO

  def new
    @dynamic = ["true", "1"].include?(params[:dynamic]) # TODO patch String to_bool
    @media_set = current_user.media_sets.build
    @media_set.query = params[:query] if @dynamic
  end

  def create
    @media_set = current_user.media_sets.create # OPTIMIZE validates_presence_of title
    if @media_set.update_attributes(params[:media_set]) # TODO ?? find_by_id_or_create_by_title
      #temp# flash[:notice] = "Media::Set successful created"
      redirect_to user_media_sets_path(current_user)
    else
      flash[:notice] = @media_set.errors.full_messages
      render :action => :new
    end
  end

  def edit
  end

#old ??#
#  def update
#    @media_set.update_attributes(params[:media_set])
#
#    respond_to do |format|
#      format.html { redirect_to @media_set }
#      format.js {
#        meta_datum = @media_set.meta_data.get(params[:media_set][:meta_data_attributes]['0'][:meta_key_id].to_i)
#        render :partial => "/meta_data/show", :locals => { :meta_datum => meta_datum, :resource => @media_set }
#      }
#    end
#  end

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
      if params[:media_entry_ids]
        media_entries = MediaEntry.find(params[:media_entry_ids])
        new_members = @media_set.media_entries.push_uniq(media_entries) 
      end
      flash[:notice] = "#{new_members} new media entries added to media_set #{@media_set.title}" if new_members > 0
      respond_to do |format|
        format.html { redirect_to(new_members > 1 ? @media_set : media_entries) } # OPTIMIZE
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
    resource = @media_set
    not_authorized! unless Permission.authorized?(current_user, action, resource) # TODO super ??
  end

  def pre_load
      params[:media_set_id] ||= params[:id]
      @user = User.find(params[:user_id]) unless params[:user_id].blank?
      @media_set = (@user? @user.media_sets : Media::Set).find(params[:media_set_id]) unless params[:media_set_id].blank? # TODO shallow
      @context = MetaContext.find(params[:context_id]) unless params[:context_id].blank?
  end

end
