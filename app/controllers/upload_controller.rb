# -*- encoding : utf-8 -*-
class UploadController < ApplicationController

  layout "upload"

  before_filter :only => [:show, :permissions, :edit, :update, :import_summary, :destroy] do
    @media_entries = current_user.incomplete_media_entries
  end

##################################################
# step 1

  def show
  end
    
  def create
    files = if params[:file]
      Array(params[:file])
    elsif params[:import_path]
      Dir.glob(File.join(params[:import_path], '**', '*')).select {|x| not File.directory?(x) }
    elsif params[:read_dropbox]
      Dir.glob(File.join(AppSettings.dropbox_root_dir, current_user.dropbox_dir, '**', '*')).select {|x| not File.directory?(x) }
    else
      raise "No files to import!"
    end

    files.each do |f|
      uploaded_data = if params[:file]
        f
      else
        ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f)),
                                               :tempfile=> File.new(f, "r"),
                                               :filename=> File.basename(f))
      end

      media_entry = current_user.incomplete_media_entries.create(:uploaded_data => uploaded_data)
      
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

  #working here#
  def dropbox_dir
    # TODO create dropbox for user with permissions
    respond_to do |format|
      format.js { render :json => {:dropbox_dir => current_user.dropbox_dir} }
    end
  end

##################################################
# step 2
# NOTE get permissions_upload_path

##################################################
# step 3

  def edit
    @context = MetaContext.upload
  end

  def update
    params[:resources][:media_entry_incomplete].each_pair do |key, value|
      media_entry = @media_entries.detect{|me| me.id == key.to_i } #old# .find(key)
      media_entry.update_attributes(value)
      media_entry.set_as_complete
    end

    render :action => :set_media_sets
  end

##################################################
# step 4

  def set_media_sets
    if request.post?
      params[:media_set_ids].delete_if {|x| x.blank?}

      media_entries = current_user.media_entries.find(params[:media_entry_ids])
      media_sets = MediaSet.find_by_id_or_create_by_title(params[:media_set_ids], current_user)
      media_sets.each do |media_set|
        media_set.media_entries.push_uniq media_entries
      end
    
      redirect_to root_path
    end
  end

##################################################

  def import_summary
    @context = MetaContext.upload
    @all_valid = @media_entries.all? {|me| me.context_valid?(@context) }
    @media_entries.each {|me| me.set_as_complete } if @all_valid
  end
  
##################################################

  def destroy
    respond_to do |format|
      format.html{ render :text => "JSON only API", :status => 406 }
      format.json{
        @media_entries.destroy_all
        render :json => {}
      }
    end
  end

##################################################

  private
  

end
