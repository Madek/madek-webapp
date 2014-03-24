# this modules contains methods used during import
# most of this used to be triggered by before_create and after_create hooks
#
module MediaResourceModules
  module Importer
    extend ActiveSupport::Concern

    module ClassMethods

      def create_with_media_file_and_previews! user, file_path, _options= {}
        options = _options.deep_symbolize_keys
        file= File.new(file_path)
        extname= options[:extname] || File.extname(file_path)
        content_type= options[:content_type] || Rack::Mime.mime_type(extname)
        media_entry_incomplete = user.incomplete_media_entries.create! 
        media_file= ::MediaFile.create! \
          media_entry: media_entry_incomplete,
          size: options[:size] || file.size,
          filename: options[:basename] || File.basename(file_path),
          content_type: content_type,
          extension: extname.downcase.gsub(/^\./,''),
          media_type: ::MediaFile.media_type(content_type)
        media_file.move_temp_file_to_storage_location! file_path
        media_file.import_meta_data
        media_file.create_previews!
        media_entry_incomplete
      end
    end

    def extract_and_set_meta_data!
      extract_and_process_subjective_metadata
      save!
      if descr_author_value = meta_data.get("description author", false).try(:value)
        meta_data.get("description author before import").update_attributes(value: descr_author_value) 
      end
    end

    def set_meta_data_for_importer! user
      mdu = meta_data.get("uploaded by")
      mdu.users << user
      mdu.save
    end

  end
end
