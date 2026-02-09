module Modules
  module MediaEntries
    module Checksum
      extend ActiveSupport::Concern

      def generate_checksum
        media_entry = get_authorized_resource
        media_file = media_entry.media_file

        media_file.generate_checksum!

        respond_to do |format|
          format.json do
            render json: {
              checksum: media_file.checksum
            }
          end
        end
      end

      def verify_checksum
        media_entry = get_authorized_resource
        media_file = media_entry.media_file

        match = media_file.verify_checksum!

        respond_to do |format|
          format.json do
            render json: {
              checksum: media_file.checksum,
              checksum_verified_at: media_file.checksum_verified_at,
              match: match
            }
          end
        end
      end

    end
  end
end
