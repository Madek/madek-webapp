# -*- encoding : utf-8 -*-

class DownloadController < ApplicationController

  # e.g.
  # 'update' param present means original file updated by exiftool with current state of madek meta-data for that mediaentry
  # update not present? just give the original file, as it was uploaded.
  # WE SHOULD NEVER UPDATE AN UPLOADED FILE WITH MADEK METADATA.
  def download
      unless params[:id].blank? 
        @size = params[:size].try(:to_sym)

        # determine correct permission and get media_entry or fail:
        begin
          # NOTE: does same check as below - blank 'size' params means download!
          needs_permission = if @size.blank? then :download else :view end
          @media_entry = MediaEntry
                          .accessible_by_user(current_user, needs_permission)
                          .find(params[:id])
        rescue
          raise UserUnauthorizedError unless current_user.login.present?
          raise UserForbiddenError
        end
        @filename = @media_entry.media_file.filename
        @content_type = @media_entry.media_file.content_type

        if params[:type] == "tms"
          send_tms
        elsif params[:type] == "xml"
          send_xml
        elsif !params[:update].blank?
          # An updated file - updated with the current set of madek meta-data  
          path, content_type = @media_entry.updated_resource_file(false, @size) # false means we don't want to blank all the tags
          send_file_with_correct_extension(path, @filename, content_type)

        elsif !params[:naked].blank?
          # A bare file - as little meta-data as can be allowed without breaking the file.  
          path, content_type = @media_entry.updated_resource_file(true, @size) # true means we do want to blank all the tags
          send_file_with_correct_extension(path, @filename, content_type)
          
        # We use @size to find out if we have to send a resized preview -- this is pretty bad
        elsif !@size.blank?
          send_preview
        else
          send_original_file
        end
        
      end
  end 
  
  def send_preview
    preview_type = @media_entry.media_file.video_type? ? "video/mp4" : nil
    preview = @media_entry.media_file.get_preview(@size, preview_type)
    @content_type = preview.content_type
    @filename = [@filename.split('.', 2).first, preview.filename.gsub(@media_entry.media_file.guid, '')].join
    path = preview.full_path
    fixed_send_file(path,
                   {:filename => @filename,
                    :type          =>  @content_type,
                    :disposition  =>  'attachment'})
  end
    
  def send_original_file
    # Provide a copy of the original file, not updated or nuffin'
    path = @media_entry.media_file.file_storage_location.to_s
    path = Pathname.new(path)
    fixed_send_file(path,
                    {:filename => @filename,
                     :type          =>  @content_type,
                     :disposition  =>  'attachment'})
  end
  
  def send_multimedia_preview
    fixed_send_file(@path,
                   {:filename => @filename,
                    :type          =>  @content_type,
                    :disposition  =>  'attachment'})
  end

  # Export a media entry xml file
  def send_xml
    data = @media_entry.to_xml(:include => {:meta_data => {:include => :meta_key}})
    send_data(data, { :filename => "#{@filename}.xml",
                      :type => :xml,
                      :disposition => 'attachment'})

  end

  # Export a media entry xml file, for tms (The Museum System)
  def send_tms
    data = MediaEntry.to_tms_doc(@media_entry)
    send_data(data, { :filename => "#{@filename}.tms.xml",
                      :type => :xml,
                      :disposition => 'attachment'})
  end

  private

  # send_file() as above seems to be broken in Rails 3.1.3 and onwards?
  # The Rack::Sendfile#call method never seems to receive a body that respons to :to_path, even though it SHOULD,
  # therefore Sendfile is never triggered (!!), that's why we need this hacked Sendfile header implementation
  def fixed_send_file(path, options = {})
    headers["Content-Type"] = options[:type]
    headers["Content-Disposition"] = "attachment; filename=\"#{options[:filename]}\""
    headers["X-Sendfile"] = path.to_s
    headers["Content-Length"] = '0'
    render :nothing => true
  end

  def send_file_with_correct_extension(path, filename, content_type)
    begin
      raise ArgumentError.new "path must not be nil" unless path
      raise ArgumentError.new "path must exist" unless File.exists? path
      e = File.extname(path)
      f = File.extname(filename)
      fixed_send_file(path,
                      {:filename => (!e.blank? and e != f) ? "#{filename}#{e}" : filename,
                        :type          =>  content_type,
                        :disposition  =>  'attachment'})            
    rescue Exception => e 
      Rails.logger.error Formatter.exception_to_log_s e
      raise e
    end
  end

end
