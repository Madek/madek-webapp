# -*- encoding : utf-8 -*-

class ImportController < ApplicationController

  before_filter :except => [:create, :dropbox_dir] do
    @media_entry_incompletes = @media_entries = current_user.incomplete_media_entries.order("ID ASC")
  end

  def start
    @dropbox_files = current_user.dropbox_files
    respond_to do |format|
      format.html { 
        do_not_cache 
        @user_dropbox_exists = !!current_user.dropbox_dir
        @dropbox_info = dropbox_info
      }
      format.json { render :json => @dropbox_files }
    end
  end
    
  def upload
    respond_to do |format|
      format.js { # this is used by Plupload
        uploaded_data = params[:file] ? params[:file] : raise("No file to import!")
        media_entry_incomplete = current_user.incomplete_media_entries.create(:uploaded_data => uploaded_data)
        raise "Import failed!" unless media_entry_incomplete.persisted?
        Rails.cache.delete "#{current_user.id}/media_entry_incompletes_partial"
        render :json => {"media_entry_incomplete" => {"id" => media_entry_incomplete.id} }
      } 
    end
  end

  def dropbox_import
    respond_to do |format|
      format.json {
        begin
          current_user.dropbox_files.each do |f|
            file = File.join(current_user.dropbox_dir, f[:dirname], f[:filename])
            media_entry_incomplete = current_user.incomplete_media_entries
              .create(:uploaded_data => ActionDispatch::Http::UploadedFile
                .new(:type=> Rack::Mime.mime_type(File.extname(file)),
                     :tempfile=> File.new(file, "r"),
                     :filename=> File.basename(file)))
            raise "Import failed!" unless media_entry_incomplete.persisted?
          end
          Rails.cache.delete "#{current_user.id}/media_entry_incompletes_partial"
          render :json => current_user.dropbox_files.length
        rescue  Exception => e
          render json: e, status: :unprocessable_entity
        end
      }
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

##################################################

  before_filter lambda {
    @media_entry_incompletes_partial = if Rails.cache.exist? "#{current_user.id}/media_entry_incompletes_partial"
       Rails.cache.read("#{current_user.id}/media_entry_incompletes_partial")
    else
      partial = render_to_string :partial => "media_resources/wrapper", 
                                 :locals => {:media_resources => @media_entry_incompletes, 
                                 :phl => true,
                                 :with_actions => false}
      Rails.cache.write "#{current_user.id}/media_entry_incompletes_partial", partial, :expires_in => 1.day
      partial
    end
    @media_entry_incompletes_collection_id = Collection.add(@media_entry_incompletes.pluck(:id))[:id]
  }, only: [:permissions, :meta_data, :organize]

  def permissions
  end 

  def meta_data
    flash[:notice] = nil # hide permission changed flash
    @context = MetaContext.upload
  end

  def organize
    unless @media_entries.all? {|me| me.context_valid?(MetaContext.upload) }
      flash[:error] = "Bitte füllen Sie für alle Medieneinträge die Pflichtfelder aus."
      redirect_to meta_data_import_path(:show_invalid_resources => true)
    end
  end

##################################################

  def complete

    if @media_entries.all? {|me| me.context_valid?(MetaContext.upload) }

      ZencoderJob.create_zencoder_jobs_if_applicable(@media_entries).each{|job| job.submit}

      @media_entries.each {|me| me.set_as_complete }
      flash[:notice] = "Import abgeschlossen."
      redirect_to my_dashboard_path
    else
      flash[:error] = "Bitte füllen Sie für alle Medieneinträge die Pflichtfelder aus."
      redirect_to meta_data_import_path(:show_invalid_resources => true)
    end
  end

##################################################

  def destroy
     respond_to do |format|
       
        format.html do
          # we are canceling the full import, but not deleting
          # @media_entries.destroy_all # NOTE: the user is not excepting that anything is getting deleted just redirect
          flash[:notice] = "Import abgebrochen."
          redirect_to my_dashboard_path
        end
        
        format.json do
          # we deleting a single media_entry_incomplete or dropbox file
          if params[:media_entry_incomplete]
            if (media_entry_incomplete = current_user.incomplete_media_entries.find params[:media_entry_incomplete][:id])
              media_entry_incomplete.destroy
              Rails.cache.delete "#{current_user.id}/media_entry_incompletes_partial"
              render :json => params[:media_entry_incomplete]
            else
              render :json => "MediaEntryIncomplete not found", :status => 500
            end
          elsif params[:dropbox_file]
            user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, current_user.dropbox_dir_name)
            if (f = File.join(user_dropbox_root_dir, params[:dropbox_file][:dirname], params[:dropbox_file][:filename]))
              File.delete(f)
              Rails.cache.delete "#{current_user.id}/media_entry_incompletes_partial"
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
  
    def dropbox_info
      if AppSettings.dropbox_root_dir and File.directory?(AppSettings.dropbox_root_dir)    
        { server: AppSettings.ftp_dropbox_server,
          login: AppSettings.ftp_dropbox_user,
          password: AppSettings.ftp_dropbox_password,
          dir_name: current_user.dropbox_dir_name }
      end
    end

end
