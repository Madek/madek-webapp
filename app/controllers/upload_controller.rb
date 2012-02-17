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
      user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, current_user.dropbox_dir_name)
      @dropbox_exists = File.directory?(user_dropbox_root_dir)
      @dropbox_info = dropbox_info 
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
    uploaded_data = if params[:file]
      params[:file]
    elsif params[:dropbox_file]
      user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, current_user.dropbox_dir_name)
      f = Dir.glob(File.join(user_dropbox_root_dir, '**', '*')).detect {|x| File.path(x) == File.join(user_dropbox_root_dir, params[:dropbox_file][:dirname], params[:dropbox_file][:filename]) }
      ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f)),
                                             :tempfile=> File.new(f, "r"),
                                             :filename=> File.basename(f))
    else
      raise "No file to import!"
    end

    media_entry = current_user.incomplete_media_entries.create(:uploaded_data => uploaded_data)

    if media_entry.persisted?
      File.delete(f) if params[:dropbox_file]
    else
      # OPTIMIZE
      raise "Import failed!"
    end

    respond_to do |format|
      format.html { redirect_to upload_path } # NOTE we need this for the Plupload html fallback
      format.js { render :json => {} } # NOTE this is used by Plupload
      format.json { render :json => {"dropbox_file" => params[:dropbox_file] } }
    end
  end

  def dropbox
    if request.post?
      if AppSettings.dropbox_root_dir
        user_dropbox_root_dir = Dir.mkdir(File.join(AppSettings.dropbox_root_dir, current_user.dropbox_dir_name))
      else
        raise "The dropbox root directory is not yet defined. Contact the administrator."
      end
    end
    respond_to do |format|
      format.json { render :json => dropbox_info }
    end
  end
  
  # NOTE helper method
  def dropbox_info
    {:server => AppSettings.ftp_dropbox_server,
     :login => AppSettings.ftp_dropbox_login,
     :password => AppSettings.ftp_dropbox_password,
     :dir_name => current_user.dropbox_dir_name}
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
    if @media_entries.all? {|me| me.context_valid?(MetaContext.upload) }
      @media_entries.each {|me| me.set_as_complete }
      redirect_to root_path
    else
      # OPTIMIZE
      flash[:error] = "Some media_entries is not valid."
      redirect_to set_media_sets_upload_path
    end
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
