# -*- encoding : utf-8 -*-
class MediaEntriesController < ApplicationController

  include Concerns::PreviousIdRedirect
  include Concerns::CustomUrls

  skip_before_filter :login_required, :only => [:document]

  before_action :the_messy_before_filter, except: [:show, :document] 
  before_action :set_instance_vars, :only => [:map, :more_data, :relations, :contexts]

  # TODO, what a MESS, this has to go!  
  def the_messy_before_filter 
    if [:edit_multiple, :update_multiple, :remove_multiple].include? request[:action].to_sym
      begin
        if !params[:media_set_id].blank?
          action = case request[:action].to_sym
            when :remove_multiple
              :edit
            else
              :view
          end
          @media_set = MediaSet.accessible_by_user(current_user, action).find(params[:media_set_id])
        elsif not params[:media_entry_ids].blank? or not params[:collection_id].blank?
          selected_ids = if params[:collection_id] 
            MediaResource.by_collection(params[:collection_id])
          else
            params[:media_entry_ids].split(",").map{|e| e.to_i }
          end
          action = case request[:action].to_sym
            when :edit_multiple, :update_multiple
              :edit
            when :remove_multiple
              :view
            else
              :view
          end
          @media_entries = MediaEntry.accessible_by_user(current_user, action).find(selected_ids)
        else
          flash[:error] = "Sie haben keine Medieneinträge ausgewählt."
          redirect_to :back
        end
      rescue
        raise UserUnauthorizedError if current_user.login.nil?
        raise UserForbiddenError
      end

    else

      @user = User.find(params[:user_id]) unless params[:user_id].blank?
      @context = Context.find(params[:context_id]) unless params[:context_id].blank?
      @media_set = (@user? @user.media_sets : MediaSet).find(params[:media_set_id]) unless params[:media_set_id].blank? # TODO shallow
  
      unless (params[:media_entry_id] ||= params[:id] || params[:media_entry_ids]).blank?
        action = case request[:action].to_sym
          when :show, :map, :browse, :media_sets
            :view
          when :update
            :edit
          when :document
            :download
          else
            :view
        end
  
        begin
          @media_entry =  if @media_set
                            @media_set.child_media_resources.media_entries.accessible_by_user(current_user, action).find(params[:media_entry_id])
                          elsif @user
                            @user.media_entries.accessible_by_user(current_user, action).find(params[:media_entry_id])
                          # TODO if @user and @media_set ??
                          else
                            MediaResource.media_entries_or_media_entry_incompletes.accessible_by_user(current_user, action).find(params[:media_entry_id])
                          end
        rescue
          raise UserUnauthorizedError if current_user.login.nil?
          raise UserForbiddenError
        end
      end
    end

  end

#####################################################
  

  def set_instance_vars
    @main_context_group = ContextGroup.sorted_by_position.first
    @can_download = current_user.try(:authorized?, :download, @media_entry)
    @can_edit = current_user.try(:authorized?, :edit, @media_entry)
    @original_file = @media_entry.media_file
    @original_file_available = (@original_file and File.exist?(@original_file.file_storage_location)) # NOTE it could be a zip file
    @format_original_file = view_context.file_format_for(@original_file)
    @preview_size = @media_entry.media_file.video_type? ? :large : :x_large
    @x_large_file = @media_entry.media_file.get_preview(@preview_size)
    @x_large_file_available = (@x_large_file and File.exist?(@x_large_file.full_path))
  end 


  def check_and_initialize_for_view
    @media_entry = find_media_resource
    raise "Wrong type" unless @media_entry.is_a? MediaEntry
    raise UserUnauthorizedError if current_user.login.nil? && @media_entry.view == false
    raise UserForbiddenError unless current_user.try(:authorized?, :view, @media_entry) || @media_entry.view == true

    # here, everything is initialized that we need everywhere (Tabs!)

    # relations stuff - TODO: remove duplication with MediaSets
    @parents = @media_entry.parent_sets
      .accessible_by_user(current_user, :view)

    # siblings: all children of all my parents, excluding myself
    @siblings = @parents.map { |parent|
      parent.child_media_resources
        .accessible_by_user(current_user, :view)
        .select { |child|
          (child.is_a? MediaSet) && (child != @media_set)
        }
    }.flatten

    @has_any_relations = [@parents, @siblings].any? { |list|
      list && list.count > 0
    }
  end

  def show
    check_and_initialize_for_view
    set_instance_vars
  end

  def document
    check_and_initialize_for_view
    set_instance_vars
    respond_to do |format|
      format.html
    end
  end
  
  def map
    check_and_initialize_for_view
    meta_data = @media_entry.media_file.meta_data
    @lat = meta_data["GPS:GPSLatitude"]
    @lng = meta_data["GPS:GPSLongitude"]

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def browse
  end

  def more_data
    check_and_initialize_for_view
    @edit_sessions = @media_entry.edit_sessions.limit(5)
    @objective_meta_data = [["Filename", @media_entry.media_file.filename]] + @media_entry.media_file.meta_data_without_binary.sort
  end

  def relations # TODO: some duplication with MediaSets#relations
    check_and_initialize_for_view
  end

  def contexts
    check_and_initialize_for_view
    @contexts= @media_entry.individual_contexts
  end
  
  def media_sets(parent_media_set_ids = params[:parent_media_set_ids])
    parent_media_sets = MediaSet.accessible_by_user(current_user, :edit).where(:id => parent_media_set_ids.map(&:to_i))

    parent_media_sets.each do |media_set|
      if request.post?
        media_set.child_media_resources << @media_entry
      else
        media_set.child_media_resources.delete(@media_entry)
      end
    end
    
    respond_to do |format|
      format.json {
        render json: view_context.json_for(parent_media_sets)
      }
    end
  end
  
#####################################################
# BATCH actions

  def remove_multiple
    @media_set.child_media_resources.delete(@media_entries)
    flash[:notice] = "Die Medieneinträge wurden aus dem Set entfernt."
    redirect_to media_set_url(@media_set)
  end
  
  def edit_multiple
    @contexts = @media_entries.map(&:individual_contexts).inject(&:&) # individual contexts common to all
    @contexts = (Context.defaults + @contexts).flatten
    @meta_data = {}
    @contexts.each {|context| @meta_data[context.id] = MediaEntry.compared_meta_data(@media_entries, context) }
  end
  
  def update_multiple
    ActiveRecord::Base.transaction do
      @media_entries.each do |media_entry|
        meta_data_attributes= params[:resource].try(:[],'meta_data_attributes')
        to_be_updated_meta_data_attributes=
          meta_data_attributes.select do |_,new_meta_datum|
            if (not new_meta_datum['value'].blank?)
              true
            elsif (not new_meta_datum['keep_original_value'])
              true
            else
              false
            end
          end
        if media_entry.set_meta_data meta_data_attributes: to_be_updated_meta_data_attributes
          media_entry.editors << current_user 
          media_entry.touch
          flash[:notice] = "Die Änderungen wurden gespeichert." 
        else
          flash[:error] = "Die Änderungen wurden nicht gespeichert." 
        end
      end
      redirect_back_or_default(root_path)
    end
  end

end

