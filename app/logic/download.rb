# -*- encoding : utf-8 -*-

class Download
  def self.call(env)
      request = Rack::Request.new(env)
      params = request.params
      session = env['rack.session']
      
      current_user = User.find_by_id(session[:user_id]) if session[:user_id]
      # TODO permission check

# e.g.
# 'zip' param present means original file + xml sidecar of meta-data all zipped as one file
# 'update' param present means original file updated by exiftool with current state of madek meta-data for that mediaentry
# (update and zip should be treated as mutally exclusive in the context of one download call)
# neither zip nor update present? just give the original file, as it was uploaded.
# WE SHOULD NEVER UPDATE AN UPLOADED FILE WITH MADEK METADATA.

#####################################################################################################################
#####################################################################################################################

      
      unless params['id'].blank? 

        @media_entry = MediaEntry.where(:id => params['id']).first

        unless @media_entry.nil?

          # This is broken, presumably because of ruby 1.8.x not having any native idea of character encodings.
          # If we move the gsub to execute after the unescape has processed, we can easily lose part of the 
          # filename if it contains diacritics and spaces.
          filename = CGI::unescape(@media_entry.media_file.filename.gsub(/\+/, '_'))
          is_preview = (!params['size'].nil? or !params['video_thumbnail'].nil? or !params['audio_preview'].nil?)
          if is_preview
            return [500, {"Content-Type" => "text/html"}, ["Sie haben nicht die notwendige Zugriffsberechtigung."]] unless Permission.authorized?(current_user, :view, @media_entry) 
            
            size = params['size'].try(:to_sym)
                        
            # This isn't video or audio, it's a plain old image
            if (!size.nil? and params['video_thumbnail'].nil? and params['audio_preview'].nil?)
              preview = @media_entry.media_file.get_preview(size)
              content_type = preview.content_type
              filename = [filename.split('.', 2).first, preview.filename.gsub(@media_entry.media_file.guid, '')].join
              
            # Video files get a WebM preview file
            elsif !params['video_thumbnail'].nil?
              content_type = "video/webm"
              preview = @media_entry.media_file.previews.where(:content_type => content_type).last
              if preview.nil?
                return [404, {"Content-Type" => "text/html"}, ["Preview file not found."]]
              else
                filename = preview.filename # The filename going out to the browser
                path = "#{THUMBNAIL_STORAGE_DIR}/#{@media_entry.media_file.shard}/#{preview.filename}"
                # this return seems to be handled later on anyhow                
                #return [200, {"Content-Type" => content_type, "Content-Disposition" => "attachment; filename=#{@media_entry.media_file.filename}" }, [File.read(path) ]]
              end     
              
            # Audio files get an Ogg Vorbis preview file
            elsif !params['audio_preview'].nil?
              content_type = "audio/ogg"
              preview = @media_entry.media_file.previews.where(:content_type => content_type).last
              if preview.nil?
                return [404, {"Content-Type" => "text/html"}, ["Preview file not found."]]
              else
                filename = preview.filename # The filename going out to the browser
                path = "#{THUMBNAIL_STORAGE_DIR}/#{@media_entry.media_file.shard}/#{preview.filename}"
                # this return seems to be handled later on anyhow
                #return [200, {"Content-Type" => content_type, "Content-Disposition" => "attachment; filename=#{@media_entry.media_file.filename}" }, [File.read(path) ]]
              end
              
            # This isn't any preview we can handle
            else
              return [500, {"Content-Type" => "text/html"}, ["Don't know how to handle this type of preview."]]
            end
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
              
              # FIXME yaml not working properly anymore!
              # YAML::ENGINE.yamler='psych'
              # zos.put_next_entry("#{filename}.yml")
              # zos.print @media_entry.to_yaml(:include => {:meta_data => {:include => :meta_key}} )
              # YAML::ENGINE.yamler='syck'
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
