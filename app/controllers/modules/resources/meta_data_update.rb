module Modules
  module Resources
    module MetaDataUpdate
      extend ActiveSupport::Concern

      # TODO: extract more from {MediaEntries,Collections}MetaDataUpdate

      def edit_meta_data
        represent(find_resource)
      end

      def meta_data_update
        resource = get_authorized_resource

        errors = update_all_meta_data_transaction!(resource, meta_data_params)

        if errors.empty?
          respond_with(resource, location: \
            -> { self.send("#{controller_name.singularize}_path", resource) })
        else
          render json: { errors: errors }, status: :bad_request
        end
      end
    end
  end
end
