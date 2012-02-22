# -*- encoding : utf-8 -*-

class DownloadController < ApplicationController
  def download
    
# e.g.
# 'zip' param present means original file + xml sidecar of meta-data all zipped as one file
# 'update' param present means original file updated by exiftool with current state of madek meta-data for that mediaentry
# (update and zip should be treated as mutally exclusive in the context of one download call)
# neither zip nor update present? just give the original file, as it was uploaded.
# WE SHOULD NEVER UPDATE AN UPLOADED FILE WITH MADEK METADATA.

#####################################################################################################################
#####################################################################################################################

      unless params[:id].blank? 

        @media_entry = MediaEntry.accessible_by_user(current_user).where(:id => params[:id]).first

        if @media_entry.nil?
          not_authorized!
        else
          # This is broken, presumably because of ruby 1.8.x not having any native idea of character encodings.
          # If we move the gsub to execute after the unescape has processed, we can easily lose part of the 
          # filename if it contains diacritics and spaces.       
          @filename = CGI::unescape(@media_entry.media_file.filename.gsub(/\+/, '_'))

          @size = params[:size].try(:to_sym)           
          @content_type = @media_entry.media_file.content_type

          if !params[:zip].blank?
            send_as_zip
          elsif !params[:update].blank?
            send_updated_file
          elsif !params[:naked].blank?
            send_naked_file
            
          # Video files get a WebM preview file
          elsif !params[:video_thumbnail].blank?
            @content_type = "video/webm"
            preview = @media_entry.media_file.previews.where(:content_type => @content_type).last
            if preview.nil?
              render :text => 'Preview file not found.', :status => 404
            else
              @filename = preview.filename # The filename going out to the browser
              @path = "#{THUMBNAIL_STORAGE_DIR}/#{@media_entry.media_file.shard}/#{preview.filename}"
              send_multimedia_preview
            end
            
          # Audio files get an Ogg Vorbis preview file            
          elsif !params[:audio_preview].blank?
            @content_type = "audio/ogg"
            preview = @media_entry.media_file.previews.where(:content_type => @content_type).last
            if preview.nil?
              render :text => 'Preview file not found.', :status => 404
            else
              @filename = preview.filename # The filename going out to the browser
              @path = "#{THUMBNAIL_STORAGE_DIR}/#{@media_entry.media_file.shard}/#{preview.filename}"
              send_multimedia_preview
            end
            
          # We use @size to find out if we have to send a resized preview -- this is pretty bad
          elsif !@size.blank?
            send_preview
          else
            send_original_file
          end
          
        end
      end

  end # download 
  
  
  def send_preview
    # This isn't video or audio, it's a plain old image
    preview = @media_entry.media_file.get_preview(@size)
    @content_type = preview.content_type
    @filename = [@filename.split('.', 2).first, preview.filename.gsub(@media_entry.media_file.guid, '')].join
    
    # Provide a copy of the original file, not updated or nuffin'
    path = @media_entry.media_file.file_storage_location
    if @size
      outfile = File.join(DOWNLOAD_STORAGE_DIR, @filename)
      `convert "#{path}" -resize "#{THUMBNAILS[@size]}" "#{outfile}"`
      path = outfile
    end
    fixed_send_file(path,
                   {:filename => @filename,
                    :type          =>  @content_type,
                    :disposition  =>  'attachment'})

  end
  
  
  # A media file updated with current madek meta-data, zipped up together with a bunch of side-car meta-data files.
  # At present these are yaml and xml files, but they are pretty raw ATM - exposing the internals of the model/schema
  # instead of following a well formed and easier to comprehend xml/yml schema..
  def send_as_zip
    path = @media_entry.updated_resource_file(false, @size) # false means we don't want to blank all the tags

    # create the zipfile - we need a name that hopefully won't collide as it's being written to..
    race_free_filename = [Time.now.to_i.to_s, @media_entry.id.to_s, @filename].join("_")

    Zip::ZipOutputStream.open("#{ZIP_STORAGE_DIR}/#{race_free_filename}.zip") do |zos|
      zos.put_next_entry(@filename)
      zos.print IO.read(path)
      zos.put_next_entry("#{@filename}.xml")
      zos.print @media_entry.to_xml(:include => {:meta_data => {:include => :meta_key}} )
      
      # FIXME yaml not working properly anymore!
      # YAML::ENGINE.yamler='psych'
      # zos.put_next_entry("#{filename}.yml")
      # zos.print @media_entry.to_yaml(:include => {:meta_data => {:include => :meta_key}} )
      # YAML::ENGINE.yamler='syck'
    end

    if path
        fixed_send_file("#{ZIP_STORAGE_DIR}/#{race_free_filename}.zip",
                        {:filename => "#{race_free_filename}.zip",
                         :type          =>  @content_type,
                         :disposition  =>  'attachment'})  
    else
      render :status => 500
    end

    # TODO - Background job submission to remove the unlocked (ie downloaded) zipfile.
    # since it fails if we try here (because the file is locked while the user 
    # downloads it at some arbitrarily slow speed)
  end
  
  
  # An updated file - updated with the current set of madek meta-data  
  def send_updated_file
    # path = @media_entry.media_file.update_file_metadata(@media_entry.to_metadata_tags)
    path = @media_entry.updated_resource_file(false, @size) # false means we don't want to blank all the tags
    if path
      fixed_send_file(path,
                      {:filename => @filename,
                       :type          =>  @content_type,
                       :disposition  =>  'attachment'})            
    else
      render :status => 500
    end
  end

  
  # A bare file - as little meta-data as can be allowed without breaking the file.  
  def send_naked_file
    path = @media_entry.updated_resource_file(true, @size) # true means we do want to blank all the tags

    if path
        fixed_send_file(path,
                        {:filename => @filename,
                         :type          =>  @content_type,
                         :disposition  =>  'attachment'})            
    else
      render :status => 500
    end    
  end
  
  def send_original_file
    # Provide a copy of the original file, not updated or nuffin'
    path = @media_entry.media_file.file_storage_location.to_s
    path = Pathname.new(path)

    #send_file(path,
    #           :filename => @filename,
    #           :type          =>  @content_type,
    #           :disposition  =>  'attachment')
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

  
end # class
