# -*- encoding : utf-8 -*-
class UploadController < ApplicationController

##################################################
# step 1

  def new
  end

  def estimation
    respond_to do |format|
      format.js { render :status => 200 }
    end
  end

  def show
    pre_load # OPTIMIZE
  end
  
  def create
      files = if !params[:uploaded_data].blank?
        params[:uploaded_data]
      elsif !params[:import_path].blank?
        Dir.glob(File.join(params[:import_path], '**', '*')).select {|x| not File.directory?(x) }
      else
        nil
      end

      unless files.blank?
        # OPTIMIZE append if already exists (multiple grouped posts)
        #temp# upload_session = current_user.upload_sessions.latest
        upload_session = current_user.upload_sessions.create

        files.each do |f|
          uploaded_data = if params[:uploaded_data]
            f
          else
            ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f)),
                                                   :tempfile=> File.new(f, "r"),
                                                   :filename=> File.basename(f))
          end

          media_entry = upload_session.incomplete_media_entries.create(:uploaded_data => uploaded_data)
          
          # If this is a path-based upload for e.g. video files, it's almost impossible that we've imported the title
          # correctly because some file formats don't give us that metadata. Let's overwrite with an auto-import default then.
          # TODO: We should get this information from a YAML/XML file that's uploaded with the media file itself instead.
          unless params[:import_path].blank?
            # TODO: Extract metadata from separate YAML file here, along with refactoring MediaEntry#process_metadata_blob and friends
            mandatory_key_ids = MetaKey.where(:label => ['title', 'copyright notice']).collect(&:id)
            if media_entry.meta_data.where(:meta_key_id => mandatory_key_ids).empty?
              mandatory_key_ids.each do |key_id|
                media_entry.meta_data.create(:meta_key_id => key_id, :value => 'Auto-created default during import')
              end
            end
          end

        end
      end

      # TODO check if all media_entries successfully saved
    respond_to do |format|
      format.html {
        if params[:import_path]
          redirect_to import_summary_upload_path
        else
          redirect_to upload_path
        end
      }
      format.js { render :json => {} }
    end

  end

##################################################
# step 2

  # TODO dry with PermissionsController#update_multiple
  def set_permissions
    default_params = {:view => false, :edit => false, :download => false}
    params.reverse_merge!(default_params)

    view_action, edit_action, download_action = case params[:view].to_sym
                                  when :private
                                    [default_params[:view], default_params[:edit], default_params[:download]]
                                  when :public
                                    [true, !!params[:edit], true]
                                  else
                                    [default_params[:view], default_params[:edit], default_params[:download]]
                                end
    
    pre_load # OPTIMIZE
    @media_entries.each do |media_entry|
      media_entry.download = download_action
      media_entry.edit = edit_action
      media_entry.view = view_action
    end

    if params[:view].to_sym == :zhdk_users
      zhdk_group = Group.where(:name => "ZHdK (Zürcher Hochschule der Künste)").first
      view_action, edit_action, download_action = [true, !!params[:edit], true]
      @media_entries.each do |media_entry|
        p = media_entry.grouppermissions.where(:group_id => zhdk_group.id).first
        p ||= media_entry.grouppermissions.build(:group => zhdk_group)
        p.update_attributes(:view => view_action, :edit => edit_action, :download => download_action)
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
