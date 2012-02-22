# -*- encoding : utf-8 -*-

class UploadController < ApplicationController

  layout "upload"

  before_filter :except => [:create, :dropbox_dir] do
    @media_entry_incompletes =  @media_entries = current_user.incomplete_media_entries
  end

##################################################
# step 1

  def show
    dropbox_files = unless AppSettings.dropbox_root_dir and File.directory?(AppSettings.dropbox_root_dir)
      @dropbox_exists = false
      []
    else
      user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, current_user.dropbox_dir_name)
      @dropbox_exists = File.directory?(user_dropbox_root_dir)
      @dropbox_info = dropbox_info
      #TODO perhaps merge this logic to @user.dropbox_files 
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
      f = File.join(user_dropbox_root_dir, params[:dropbox_file][:dirname], params[:dropbox_file][:filename])
      ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f)),
                                             :tempfile=> File.new(f, "r"),
                                             :filename=> File.basename(f))
    else
      raise "No file to import!"
    end

    media_entry_incomplete = current_user.incomplete_media_entries.create(:uploaded_data => uploaded_data)

    if media_entry_incomplete.persisted?
      File.delete(f) if params[:dropbox_file]
    else
      # OPTIMIZE
      raise "Import failed!"
    end

    respond_to do |format|
      format.html { redirect_to upload_path } # NOTE we need this for the Plupload html fallback
      format.js { render :json => {"media_entry_incomplete" => {"id" => media_entry_incomplete.id} } } # NOTE this is used by Plupload
      format.json { render :json => {"dropbox_file" => params[:dropbox_file], "media_entry_incomplete" => {"id" => media_entry_incomplete.id, "filename" => media_entry_incomplete.media_file.filename} } }
    end
  end

  def dropbox
    if request.post?
      if File.directory?(AppSettings.dropbox_root_dir) and
        (user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, current_user.dropbox_dir_name))
        Dir.mkdir(user_dropbox_root_dir)
        File.new(user_dropbox_root_dir).chmod(0770)
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
     :login => AppSettings.ftp_dropbox_user,
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
      flash[:error] = "Einige Medieneinträge sind ungültig"
      redirect_to set_media_sets_upload_path
    end
  end

##################################################

  
  def destroy
     respond_to do |format|
       
        format.html do
          # we are canceling the full import, but not deleting
          # @media_entries.destroy_all # NOTE: the user is not excepting that anything is getting deleted just redirect
          flash[:notice] = "Import abgebrochen"
          redirect_to root_path 
        end
        
        format.json do
          # we deleting a single media_entry_incomplete or dropbox file
          if params[:media_entry_incomplete]
            if (media_entry_incomplete = current_user.incomplete_media_entries.find params[:media_entry_incomplete][:id])
              media_entry_incomplete.destroy
              render :json => params[:media_entry_incomplete]
            else
              render :json => "MediaEntryIncomplete not found", :status => 500
            end
          elsif params[:dropbox_file]
            user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, current_user.dropbox_dir_name)
            if (f = File.join(user_dropbox_root_dir, params[:dropbox_file][:dirname], params[:dropbox_file][:filename]))
              File.delete(f)
              render :json => params[:dropbox_file]
            else
              render :json => "File not found", :status => 500
            end
          else
            render :json => {}, :status => 500
          end
        end
      end
  end

##################################################

  private
  

end
