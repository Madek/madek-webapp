# -*- encoding : utf-8 -*-
class UploadController < ApplicationController

##################################################
# step 1

  def new
  end

  def show
    pre_load # OPTIMIZE
  end
  
### metal/upload.rb ###    
#  def create
#  end

##################################################
# step 2

  # TODO dry with PermissionsController#update_multiple
  def set_permissions
    default_params = {:view => false, :edit => false, :hi_res => false}
    params.reverse_merge!(default_params)

    view_action, edit_action, hi_res_download = case params[:view].to_sym
                                  when :private
                                    [default_params[:view], default_params[:edit], default_params[:hi_res]]
                                  when :public
                                    [true, !!params[:edit], true]
                                  else
                                    [default_params[:view], default_params[:edit], default_params[:hi_res]]
                                end
    
    pre_load # OPTIMIZE
    @media_entries.each do |media_entry|
      media_entry.default_permission.set_actions(:view => view_action, :edit => edit_action, :hi_res => hi_res_download)
    end

    if params[:view].to_sym == :zhdk_users
      zhdk_group = Group.where(:name => "ZHdK (Zürcher Hochschule der Künste)").first
      view_action, edit_action, hi_res_download = [true, !!params[:edit], true]
      @media_entries.each do |media_entry|
        p = media_entry.permissions.where(:subject_type => zhdk_group.class.base_class.name, :subject_id => zhdk_group.id).first
        p ||= media_entry.permissions.build(:subject => zhdk_group)
        p.set_actions(:view => view_action, :edit => edit_action, :hi_res => hi_res_download)
      end
    end

    edit
    render :action => :edit
  end


##################################################
# step 3

  def edit
    pre_load
    @context = MetaContext.upload
  end

  def update
    pre_load
    @upload_session.set_as_complete

    params[:resources][:media_entry_incomplete].each_pair do |key, value|
      media_entry = @media_entries.detect{|me| me.id == key.to_i } #old# .find(key)
      media_entry.update_attributes(value)
    end

    # TODO delta index if new Person 

    render :action => :set_media_sets
  end


##################################################
# step 4

  def set_media_sets
    if request.post?
      params[:media_set_ids].delete_if {|x| x.blank?}

      pre_load # OPTIMIZE
      media_sets = MediaSet.find_by_id_or_create_by_title(params[:media_set_ids], current_user)
      media_sets.each do |media_set|
        media_set.media_entries.push_uniq @upload_session.media_entries
      end
    
      redirect_to root_path
    else
      # TODO is the get method really needed ??
      pre_load # OPTIMIZE
      
          #FIXME NOTE TODO REMOVE
          @media_entries = @upload_session.media_entries

    end
  end

##################################################

  def import_summary
    pre_load
    @context = MetaContext.upload
    @all_valid = @media_entries.all? {|me| me.context_valid?(@context) }
    @upload_session.set_as_complete if @all_valid
  end
  
##################################################

  private
  
  def pre_load
    @upload_session = if params[:upload_session_id]
                        current_user.upload_sessions.find(params[:upload_session_id])
                      else
                        current_user.upload_sessions.latest
                      end
    @media_entries = @upload_session.incomplete_media_entries
  end

end
