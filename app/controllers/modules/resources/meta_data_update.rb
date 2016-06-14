module Modules
  module Resources
    module MetaDataUpdate
      extend ActiveSupport::Concern

      # TODO: extract more from {MediaEntries,Collections}MetaDataUpdate

      def edit_meta_data
        represent(find_resource)
      end

      def edit_context_meta_data
        resource = find_resource
        @get = Presenters::MetaData::EditContextMetaData.new(
          resource,
          current_user,
          params[:context_id])
        respond_with @get
      end

      def meta_data_update
        resource = get_authorized_resource
        errors = update_all_meta_data_transaction!(resource, meta_data_params)

        if errors.empty?

          published_before = published_state(resource)
          if params[:actionType] == 'publish'
            ActiveRecord::Base.transaction do
              resource.is_published = true
              resource.save!
            end
          end
          published_after = published_state(resource)

          determine_respond_success(resource, published_before, published_after)
        else
          respond_with_errors(errors)
        end
      end

      private

      def published_state(resource)
        resource.class != MediaEntry or resource.is_published
      end

      def determine_respond_success(resource, published_before, published_after)
        if published_after
          if published_before
            respond_success(
              resource,
              :success,
              'meta_data_edit_' + resource.class.name.underscore + '_saved')
          else
            respond_success(
              resource,
              :success,
              'meta_data_edit_media_entry_published')
          end
        else
          respond_success(
            resource,
            :warning,
            'meta_data_edit_media_entry_saved_missing')
        end
      end

      def respond_success(resource, type, text_key)
        flash[type] = I18n.t(text_key)
        fwd_url = self.send("#{controller_name.singularize}_path", resource)
        respond_to do |format|
          format.json { render(json: { forward_url: fwd_url }) }
          format.html { redirect_to(fwd_url) }
        end
      end

      def respond_with_errors(errors)
        respond_to do |format|
          format.json { render(json: { errors: errors }, status: :bad_request) }
          format.html do
            msg = t(:resource_meta_data_has_validation_errors) + "\n" +
              errors.values.join("\n")
            raise Errors::InvalidParameterValue, msg
          end
        end
      end

    end
  end
end
