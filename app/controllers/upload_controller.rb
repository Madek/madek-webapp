# -*- encoding : utf-8 -*-
class UploadController < ApplicationController

  layout "upload"

  before_filter :except => [:create, :dropbox_dir] do
    @media_entry_incompletes =  @media_entries = current_user.incomplete_media_entries
  end

##################################################
# step 1

  def show
    dropbox_files = unless AppSettings.dropbox_root_dir
      []
    else
      user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, current_user.dropbox_dir)
      Dir.glob(File.join(user_dropbox_root_dir, '**', '*')).
                  select {|x| not File.directory?(x) }.
                  map {|f| {:dirname=> File.dirname(f).gsub(user_dropbox_root_dir, ''),
                            :filename=> File.basename(f),
                            :size => File.size(f) } }
    end
    
    respond_to do |format|
      format.html {
        @dropbox_files_json = dropbox_files.to_json
      }
      format.json {
        render :json => dropbox_files
      }
    end
  end
    
  def create
    files = if params[:file]
      Array(params[:file])
    elsif params[:dropbox_file]
      user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, current_user.dropbox_dir)
      Array(Dir.glob(File.join(user_dropbox_root_dir, '**', '*')).detect {|x| File.path(x) == File.join(user_dropbox_root_dir, params[:dropbox_file][:dirname], params[:dropbox_file][:filename]) })
    elsif params[:import_path]
      Dir.glob(File.join(params[:import_path], '**', '*')).select {|x| not File.directory?(x) }
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
      if params[:import_path]
        # TODO: Extract metadata from separate YAML file here, along with refactoring MediaEntry#process_metadata_blob and friends
        mandatory_key_ids = MetaKey.where(:label => ['title', 'copyright notice']).collect(&:id)
        if media_entry.meta_data.where(:meta_key_id => mandatory_key_ids).empty?
          mandatory_key_ids.each do |key_id|
            media_entry.meta_data.create(:meta_key_id => key_id, :value => 'Auto-created default during import')
          end
        end
      elsif params[:dropbox_file]
        File.delete(f)
      end

    end

      # TODO check if all media_entries successfully saved
    respond_to do |format|
      format.html {
        if params[:import_path]
          redirect_to import_summary_upload_path
        else
          # NOTE we need this for the Plupload html fallback
          redirect_to upload_path
        end
      }
      format.js { render :json => {} } # NOTE this is used by Plupload
      format.json { render :json => {"dropbox_file" => params[:dropbox_file] } }
    end

  end

  def dropbox
    if request.post?
      if AppSettings.dropbox_root_dir
        user_dropbox_root_dir = Dir.mkdir(File.join(AppSettings.dropbox_root_dir, current_user.dropbox_dir))
      else
        raise "The dropbox root directory is not yet defined. Contact the administrator."
      end
    end
    respond_to do |format|
      format.js { render :json => {:dropbox => {:dir => current_user.dropbox_dir} } }
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
    end

    redirect_to set_media_sets_upload_path
  end

##################################################
# step 4

  def set_media_sets
  end

##################################################

  def complete
    @media_entries.each {|me| me.set_as_complete }
    redirect_to root_path
  end

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
