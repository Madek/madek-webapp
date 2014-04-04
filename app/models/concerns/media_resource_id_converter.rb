module Concerns
  module MediaResourceIdConverter
    extend ActiveSupport::Concern

    UUID_V4_REGEXP= /^\w{8}-\w{4}-4\w{3}-\w{4}-\w{12}$/
    INT_REGEXP= /^\d+$/

    module ClassMethods

      # map existing uuid, previous_id, or custom_url-id, to the uuid of an
      # existing media resource; returns nil if neither mapping was successful
      def some_id_to_uuid(some_id)
        case
        when UUID_V4_REGEXP.match(some_id)
          MediaResource.select("id").find_by(id: some_id).try(:id)
        when INT_REGEXP.match(some_id)
          MediaResource.select("id").find_by(previous_id: some_id).try(:id)
        else
          CustomUrl.select("media_resource_id").find_by(id: some_id).try(:media_resource_id)
        end
      end

    end

  end
end
