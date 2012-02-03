# -*- encoding : utf-8 -*-

class UploadEstimation
  def self.call(env)
    [200, {"Content-Type" => "text/html"}, [""]]
  end
end

# Utility functions during upload
class UploadUtility
  def self.detect_type(path)
    file_result = self.type_using_file(path)

    # This leads to a LOT of 'invalid byte sequence in UTF_8' problems since we started using Ruby 1.9.2.
    # Disabling for now. FIXME
    #exiftool_result = self.type_using_exiftool(path)

    # If "file" and Exiftool d# isagree, trust Exiftool
    # if [file_result, exiftool_result].compact.uniq.size > 1
    #   detected_type = exiftool_result
    # else
    #   detected_type = file_result
    # end
    
    detected_type = file_result

    return detected_type
  end
  
  def self.type_using_file(path)
    return `#{FILE_UTIL_PATH} "#{path}"`.split(";").first.gsub(/\n/,"")
  end

  def self.type_using_exiftool(path)
    exif = MiniExiftool.new(path)
    return exif['MIMEType']
  end

  def self.assign_type(f)
    # QuickTime containers contain all sorts of messy data, which makes them hard for
    # the 'file' utility to guess, resulting in a lot of application/octet-stream types.
    # But since QuickTime video is always video/quicktime and always .mov, we simply override
    # this based on the filename here.
    # TODO: Could use exiftool instead of 'file' in general, it seems to do a good job with QuickTime
    if f[:filename] =~ /.mov$/
      f[:type] = "video/quicktime"
    else
      supplied_type = f[:type]
      detected_type = UploadUtility.detect_type(f[:tempfile].path)

      if supplied_type != detected_type
        f[:type] = detected_type
      end
    end
  end
end

class Upload
  def self.call(env)
      request = Rack::Request.new(env)
      params = request.params
      session = env['rack.session']

      current_user = User.find_by_id(session[:user_id]) if session[:user_id]
      
      files = if !params['uploaded_data'].blank?
        params['uploaded_data']
      elsif !params['import_path'].blank?
        Dir[File.join(params['import_path'], '**', '*')]
      else
        nil
      end

      unless files.blank?
        # OPTIMIZE append if already exists (multiple grouped posts)
        #temp# upload_session = current_user.upload_sessions.latest
        upload_session = current_user.upload_sessions.create

        files.each do |f|
          # Mac OS X sometimes lies about the content type, so we have to detect the supplied type
          # separately from the true type
          uploaded_data = if params['uploaded_data']
            UploadUtility.assign_type(f)
            f
          else
            { :type=> UploadUtility.detect_type(f),
              :tempfile=> File.new(f, "r"),
              :filename=> File.basename(f)}
          end

          # if uploaded_data['filename'].include?
          # uploaded_data['current_user'] = current_user.login # for the use of media_file, if we get a zipfile
          media_file = MediaFile.create(:uploaded_data => uploaded_data)
          media_entry = upload_session.incomplete_media_entries.create(:media_file => media_file)
          
          # If this is a path-based upload for e.g. video files, it's almost impossible that we've imported the title
          # correctly because some file formats don't give us that metadata. Let's overwrite with an auto-import default then.
          # TODO: We should get this information from a YAML/XML file that's uploaded with the media file itself instead.
          if !params['import_path'].blank?
            # TODO: Extract metadata from separate YAML file here, along with refactoring MediaEntry#process_metadata_blob and friends
            mandatory_key_ids = MetaKey.where(:label => ['title', 'copyright notice']).collect(&:id)
            if media_entry.meta_data.where(:meta_key_id => mandatory_key_ids).empty?
              mandatory_key_ids.each do |key_id|
                media_entry.meta_data.create(:meta_key_id => key_id, :value => 'Auto-created default during import')
              end
            end
          end

          uploaded_data[:tempfile].close unless params['uploaded_data']
        end
      end

      # TODO check if all media_entries successfully saved

      if params['xhr']
        [200, {"Content-Type" => "text/html"}, [""]]
      else
        uri = if params['uploaded_data']
                "/upload"
              elsif params['import_path']
                "/upload/import_summary"
              else
                "/upload/new"
              end
        [ 303, {'Content-Length'=>'0', 'Content-Type'=>'text/plain', 'Location' => uri}, []]
      end
  end

end
