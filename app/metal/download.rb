# -*- encoding : utf-8 -*-

class Download
  def self.call(env)
      request = Rack::Request.new(env)
      params = request.params
      session = env['rack.session']
      
      current_user = User.find_by_id(session[:user_id]) if session[:user_id]

# e.g.
# 'zip' param present means original file + xml sidecar of meta-data all zipped as one file
# 'update' param present means original file updated by exiftool with current state of madek meta-data for that mediaentry
# (update and zip should be treated as mutally exclusive in the context of one download call)
# neither zip nor update present? just give the original file, as it was uploaded.
# WE SHOULD NEVER UPDATE AN UPLOADED FILE WITH MADEK METADATA.

#####################################################################################################################
#####################################################################################################################


      unless params['media_file_id'].blank?
        @media_file = MediaFile.where(:id => params['media_file_id'], :access_hash => params['access_hash']).first
        
        if @media_file.nil?
          return [404, {"Content-Type" => "text/html"}, ["Not found or no access. Try adding an access hash."]]
        else
          path = @media_file.file_storage_location
          return [200, {"Content-Type" => @media_file.content_type, "Content-Disposition" => "attachment; filename=#{@media_file.filename}" }, [File.read(path) ]]
        end
      end
      
      unless params['id'].blank? 

        @media_entry = MediaEntry.where(:id => params['id']).first

        unless @media_entry.nil?

          # This is broken, presumably because of ruby 1.8.x not having any native idea of character encodings.
          # If we move the gsub to execute after the unescape has processed, we can easily lose part of the 
          # filename if it contains diacritics and spaces.
          filename = CGI::unescape(@media_entry.media_file.filename.gsub(/\+/, '_'))
          size = params['size'].try(:to_sym)
          if size
            preview = @media_entry.media_file.get_preview(size)
            filename = [filename.split('.', 2).first, preview.filename.gsub(@media_entry.media_file.guid, '')].join
            content_type = preview.content_type
            return [500, {"Content-Type" => "text/html"}, ["Sie haben nicht die notwendige Zugriffsberechtigung."]] unless Permission.authorized?(current_user, :view, @media_entry) 
          else
            content_type = @media_entry.media_file.content_type
            return [500, {"Content-Type" => "text/html"}, ["Sie haben nicht die notwendige Zugriffsberechtigung."]] unless Permission.authorized?(current_user, :hi_res, @media_entry) 
          end


#####################################################################################################################
#####################################################################################################################
# A media file updated with current madek meta-data, zipped up together with a bunch of side-car meta-data files.
# At present these are yaml and xml files, but they are pretty raw ATM - exposing the internals of the model/schema
# instead of following a well formed and easier to comprehend xml/yml schema..
#####################################################################################################################
#####################################################################################################################
          unless params['zip'].blank?

            path = @media_entry.updated_resource_file(false, size) # false means we don't want to blank all the tags

            # create the zipfile - we need a name that hopefully won't collide as it's being written to..
            race_free_filename = [Time.now.to_i.to_s, @media_entry.id.to_s, filename].join("_")

            Zip::ZipOutputStream.open("#{ZIP_STORAGE_DIR}/#{race_free_filename}.zip") do
              |zos|
              zos.put_next_entry(filename)
              zos.print IO.read(path)
              zos.put_next_entry("#{filename}.xml")
              zos.print @media_entry.to_xml(:include => {:meta_data => {:include => :meta_key}} )
              zos.put_next_entry("#{filename}.yml")
              zos.print @media_entry.to_yaml(:include => {:include => :meta_key} )
            end

            if path
              return [200, {"Content-Type" => "application/zip", "Content-Disposition" => "attachment; filename=#{filename}.zip"}, 
                    [File.read("#{ZIP_STORAGE_DIR}/#{race_free_filename}.zip")]]
            else
              return [500, {"Content-Type" => "text/html"}, ["Something went wrong!"]]
            end

              # TODO - Background job submission to remove the unlocked (ie downloaded) zipfile.
              # since it fails if we try here (because the file is locked while the user 
              # downloads it at some arbitrarily slow speed)
          end

#####################################################################################################################
#####################################################################################################################
# An updated file - updated with the current set of madek meta-data
#####################################################################################################################
#####################################################################################################################
          unless params['update'].blank?

            # path = @media_entry.media_file.update_file_metadata(@media_entry.to_metadata_tags)
            path = @media_entry.updated_resource_file(false, size) # false means we don't want to blank all the tags
            if path
              return [200, {"Content-Type" => content_type, "Content-Disposition" => "attachment; filename=#{filename}" }, [File.read(path)]]
            else
              return [500, {"Content-Type" => "text/html"}, ["Something went wrong!"]]
            end
          end


#####################################################################################################################
#####################################################################################################################
# A bare file - as little meta-data as can be allowed without breaking the file.
#####################################################################################################################
#####################################################################################################################
          unless params['naked'].blank?

            path = @media_entry.updated_resource_file(true, size) # true means we do want to blank all the tags

            if path
              return [200, {"Content-Type" => content_type, "Content-Disposition" => "attachment; filename=#{filename}" }, [File.read(path) ]]
            else
              return [500, {"Content-Type" => "text/html"}, ["Something went wrong!"]]
            end
          end


          # A transcoded, smaller-than-original version of the video
          unless params['video_thumbnail'].blank?
            if params['format'].blank?
              video_format = "webm" # This is much more widely supported than H.264. Only Apple/Safari wants H.265
                                    # everyone else is on WebM.
            else
              video_format = params['format']
            end

            candidates = Dir.glob("#{@media_entry.media_file.file_storage_location}_encoded/*.#{video_format}")
            if candidates.empty?
              return [404, {"Content-Type" => "text/html"}, ["Not found. Try a different format, perhaps 'webm' or 'mp4'."]]
            else
              path = candidates.first
              content_type = "video/#{File.extname(path).gsub(".","")}"
              return [200, {"Content-Type" => content_type, "Content-Disposition" => "attachment; filename=#{File.basename(path)}" }, [File.read(path) ]]
            end
          end

#####################################################################################################################
#####################################################################################################################
# Provide a copy of the original file, not updated or nuffin'
#####################################################################################################################
#####################################################################################################################

          path = @media_entry.media_file.file_storage_location
          if size
            outfile = File.join(DOWNLOAD_STORAGE_DIR, filename)
            `convert "#{path}" -resize "#{THUMBNAILS[size]}" "#{outfile}"`
            path = outfile
          end
          
          # return [200, {"Content-Type" => "text/html"}, [ "#{filename.inspect}" ]] # temp debugging aid
          return [200, {"Content-Type" => content_type, "Content-Disposition" => "attachment; filename=#{filename}" }, [File.read(path) ]]
        end

      end

  end # def 
end # class
