# -*- encoding : utf-8 -*-

class ImportController < ApplicationController

  # what the heck are we doing with the cache here
  # people: the 'cache' is, well a cache, and volatile in unpredictable ways!
  # TODO have a look at this and possibly fix it together with the collections

  before_filter :except => [:create, :dropbox_dir] do
    @media_entry_incompletes = @media_entries = current_user.incomplete_media_entries.reorder(created_at: :asc, id: :asc)
  end

  def start
    @dropbox_files = current_user.dropbox_files(@app_settings)
    respond_to do |format|
      format.html { 
        do_not_cache 
        @user_dropbox_exists = !!current_user.dropbox_dir(@app_settings)
        @dropbox_info = dropbox_info 
      }
      format.json { render :json => @dropbox_files }
    end
  end
    
  def upload
    ExceptionHelper.log_and_reraise do
      ActiveRecord::Base.transaction do
        @uploaded_file= params[:file] or raise("Missing file parameter in upload!")
        original_filename= @uploaded_file.original_filename 
        @media_entry_incomplete= 
          MediaEntryIncomplete.create_with_media_file_and_previews!  \
            current_user, @uploaded_file.tempfile.path, \
            # it is saver to evaluate @uploaded_file for some properties, since
            # the tempfile could have a strange name etc.
            size: @uploaded_file.size,
            basename: original_filename,
            content_type: Rack::Mime.mime_type(File.extname(original_filename)), 
            extname: File.extname(original_filename)
        @media_entry_incomplete.extract_and_set_meta_data!
        @media_entry_incomplete.set_meta_data_for_importer! current_user
        raise "Import failed!" unless @media_entry_incomplete.persisted?
        Rails.cache.delete "#{current_user.id}/media_entry_incompletes_partial"
        render :json => {"media_entry_incomplete" => {"id" => @media_entry_incomplete.id} }
      end
    end
  end

  def dropbox_import
    begin
      current_user.dropbox_files(@app_settings).each do |f|
        ExceptionHelper.log_and_reraise do
          ActiveRecord::Base.transaction do
            path = File.join(current_user.dropbox_dir(@app_settings), f[:dirname], f[:filename])
            @media_entry_incomplete= 
              MediaEntryIncomplete.create_with_media_file_and_previews!  \
                current_user, path
            @media_entry_incomplete.extract_and_set_meta_data!
            @media_entry_incomplete.set_meta_data_for_importer! current_user
            raise "Import failed!" unless @media_entry_incomplete.persisted?
          end
        end
      end
      Rails.cache.delete "#{current_user.id}/media_entry_incompletes_partial"
      render :json => current_user.dropbox_files(@app_settings).length
    rescue  Exception => e
      render json: e, status: :unprocessable_entity
    end
  end

  def dropbox_create
    if File.directory?(@app_settings.dropbox_root_dir) \
        and (user_dropbox_root_dir = current_user.dropbox_dir_path(@app_settings))
      Dir.mkdir(user_dropbox_root_dir)
      File.new(user_dropbox_root_dir).chmod(0770)
    else
      raise "The dropbox root directory is not yet defined. Contact the administrator."
    end
    render json: dropbox_info 
  end

  def dropbox_info
    render json: dropbox_info
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
    @context = Context.find("upload")
  end

  def organize
    unless @media_entries.all? {|me| me.context_valid?(Context.find("upload")) }
      flash[:error] = "Bitte füllen Sie für alle Medieneinträge die Pflichtfelder aus."
      redirect_to meta_data_import_path(:show_invalid_resources => true)
    end
  end

##################################################

  def complete

    if @media_entries.all? {|me| me.context_valid?(Context.find("upload")) }

      # convert to complete media_entries, returns an Array
      complete =  @media_entries.map{|me| me.set_as_complete}

      # create_zencoder_jobs_if_applicable expects an ActiveRecord::Relation
      entries = MediaEntry.where(id: complete.map(&:id))
      ZencoderJob.create_zencoder_jobs_if_applicable(entries).each{|job| job.submit}
  
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
            user_dropbox_root_dir = File.join(@app_settings.dropbox_root_dir, current_user.dropbox_dir_name)
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
      if @app_settings.dropbox_root_dir and File.directory?(@app_settings.dropbox_root_dir)    
        { server: @app_settings.ftp_dropbox_server,
          login: @app_settings.ftp_dropbox_user,
          password: @app_settings.ftp_dropbox_password,
          dir_name: current_user.dropbox_dir_name }
      end
    end

end
