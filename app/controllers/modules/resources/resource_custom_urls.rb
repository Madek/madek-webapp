module Modules
  module Resources
    module ResourceCustomUrls
      extend ActiveSupport::Concern

      private

      def resource_custom_urls(resource)
        auth_authorize(resource)

        @get = Presenters::CustomUrls::ResourceCustomUrls.new(
          current_user,
          resource
        )

        respond_with(@get)
      end

      def resource_edit_custom_urls(resource)
        auth_authorize(resource)

        if params[:needs_confirmation]
          confirmation = {
            address_id: params.require(:address_id),
            from_title: params.require(:from_title),
            to_title: params.require(:to_title),
            type: params.require(:type)
          }
        end

        @get = Presenters::CustomUrls::ResourceEditCustomUrls.new(
          current_user, resource, confirmation)

        respond_with(@get)
      end

      def resource_set_primary_custom_url(resource)
        auth_authorize(resource)

        custom_url_id = params.require(:custom_url_id)

        ActiveRecord::Base.transaction do
          resource.custom_urls.each do |custom_url|
            custom_url.is_primary = custom_url.id == custom_url_id
            custom_url.save!
          end
          resource.save!
        end

        t1 = I18n.t('custom_urls_flash_primary_url_set_1')
        t2 = I18n.t('custom_urls_flash_primary_url_set_2')
        html_respond(resource, false, "#{t1}\"#{custom_url_id}\"#{t2}")
      end

      def resource_update_custom_urls(user, resource)
        auth_authorize(resource)

        address_name = params[:custom_url_name]
        confirmed = true if params[:confirmation] == 'true'

        return unless validate_not_empty(resource, address_name)
        return unless validate_address_format(resource, address_name)

        existing_url = CustomUrl.where(id: address_name).first

        if existing_url
          transfer_url(user, resource, existing_url, confirmed)
        else
          create_custom_url_transaction(user, resource, address_name)
        end
      end

      def custom_url_resource(custom_url)
        if custom_url.media_entry_id
          MediaEntry.find(custom_url.media_entry_id)
        elsif custom_url.collection_id
          Collection.find(custom_url.collection_id)
        else
          raise 'Only implemented for MediaEntry and Collection'
        end
      end

      def validate_not_empty(resource, address_name)
        return true if address_name && !address_name.empty?
        html_respond(resource, true, I18n.t('custom_urls_flash_empty'))
        false
      end

      def validate_address_format(resource, address_name)
        return true if (address_name =~ /^[a-z][a-z0-9\-\_]+$/)
        t1 = I18n.t('custom_urls_flash_wrong_format_1')
        t2 = I18n.t('custom_urls_flash_wrong_format_2')
        html_respond(resource, true, "#{t1}\"#{address_name}\"#{t2}")
        false
      end

      def validate_not_exists_on_itself(resource, current_resource, existing_url)
        return true if current_resource.id != resource.id
        type_string = resource.class.name.underscore
        t1 = I18n.t("custom_urls_flash_exists_on_itself_#{type_string}_1")
        t2 = I18n.t("custom_urls_flash_exists_on_itself_#{type_string}_2")
        html_respond(resource, true, "#{t1}\"#{existing_url.id}\"#{t2}")
        false
      end

      def validate_allowed(user, resource, current_resource, existing_url)
        return true if auth_policy(user, current_resource).update_custom_urls?
        type_string = current_resource.class.name.underscore
        t1 = I18n.t("custom_urls_flash_not_allowed_#{type_string}_1")
        t2 = I18n.t("custom_urls_flash_not_allowed_#{type_string}_2")
        t3 = I18n.t("custom_urls_flash_not_allowed_#{type_string}_3")
        message = "#{t1}\"#{existing_url.id}\"#{t2}\"#{existing_url.id}\"#{t3}"
        html_respond(resource, true, message)
        false
      end

      def validate_same_types(resource, current_resource, existing_url)
        return true if resource.class == current_resource.class
        type_string = resource.class.name.underscore
        t1 = I18n.t("custom_urls_flash_not_same_type_#{type_string}_1")
        t2 = I18n.t("custom_urls_flash_not_same_type_#{type_string}_2")
        html_respond(resource, true, "#{t1}\"#{existing_url.id}\"#{t2}")
        false
      end

      def validate_transfer(user, resource, current_resource, existing_url)
        return unless validate_not_exists_on_itself(
          resource, current_resource, existing_url)

        return unless validate_allowed(
          user, resource, current_resource, existing_url)

        return unless validate_same_types(
          resource, current_resource, existing_url)

        true
      end

      def validate_confirmed(resource, current_resource, confirmed, existing_url)
        return true if confirmed

        type_string = resource.class.name.underscore
        query_params = { needs_confirmation: true,
                         address_id: existing_url.id,
                         from_title: current_resource.title,
                         to_title: resource.title,
                         type: type_string }

        path = send("edit_custom_urls_#{type_string}_path",
                    resource, query_params)
        redirect_to path

        false
      end

      def transfer_url(user, resource, existing_url, confirmed)
        current_resource = custom_url_resource(existing_url)

        return unless validate_transfer(
          user,
          resource,
          current_resource,
          existing_url)

        return unless validate_confirmed(
          resource, current_resource, confirmed, existing_url)

        transfer_url_transaction(resource, existing_url, current_resource)
      end

      def transfer_url_transaction(resource, existing_url, current_resource)
        ActiveRecord::Base.transaction do
          do_transfer_url(resource, current_resource, existing_url)
        end

        t1 = I18n.t('custom_urls_flash_transfer_successful_1')
        t2 = I18n.t('custom_urls_flash_transfer_successful_2')
        t3 = I18n.t('custom_urls_flash_transfer_successful_3')
        t4 = I18n.t('custom_urls_flash_transfer_successful_4')
        message = "#{t1}" \
          "\"#{existing_url.id}\"" \
          "#{t2}" \
          "\"#{current_resource.title}\"" \
          "#{t3}" \
          "\"#{resource.title}\"" \
          "#{t4}"
        html_respond(resource, false, message)
      end

      def do_transfer_url(resource, current_resource, existing_url)
        target_has_no_primary = resource.custom_urls.select(&:is_primary).empty?

        existing_url.is_primary = target_has_no_primary
        resource.custom_urls << existing_url

        existing_url.save!
        current_resource.save!
        resource.save!
      end

      def create_custom_url_transaction(user, resource, address_name)
        ActiveRecord::Base.transaction do
          do_create_custom_url(user, resource, address_name)
        end

        t1 = I18n.t('custom_urls_flash_create_successful_1')
        t2 = I18n.t('custom_urls_flash_create_successful_2')
        html_respond(resource, false, "#{t1}\"#{address_name}\"#{t2}")
      end

      def do_create_custom_url(user, resource, address_name)
        first = (not resource.custom_urls) || resource.custom_urls.empty?

        custom_url = CustomUrl.new(
          id: address_name,
          is_primary: first,
          creator: user,
          updator: user
        )

        resource.custom_urls << custom_url
        resource.save!
      end

      def html_respond(resource, is_error, message)
        if is_error
          path_method = "edit_custom_urls_#{resource.class.name.underscore}_path"
          redirect_url = send(path_method, resource)
          respond_to do |format|
            format.html do
              redirect_to(redirect_url, flash: { error: message })
            end
          end
        else
          path_method = "custom_urls_#{resource.class.name.underscore}_path"
          redirect_url = send(path_method, resource)
          respond_to do |format|
            format.html do
              redirect_to(redirect_url, flash: { success: message })
            end
          end
        end
      end
    end
  end
end
