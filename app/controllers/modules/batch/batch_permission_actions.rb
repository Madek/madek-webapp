module Modules
  module Batch
    module BatchPermissionActions
      extend ActiveSupport::Concern

      include Modules::Resources::PermissionsHelpers
      include Modules::Batch::BatchAuthorization
      include Modules::Batch::BatchLogIntoEditSessions

      SANITIZATION_SPEC = \
        { MediaEntry: { user: [:get_metadata_and_previews,
                               :get_full_size,
                               :edit_metadata,
                               :edit_permissions],
                        group: [:get_metadata_and_previews,
                                :get_full_size,
                                :edit_metadata],
                        api_client: [:get_metadata_and_previews,
                                     :get_full_size],
                        public: [:get_metadata_and_previews,
                                 :get_full_size] },
          Collection: { user: [:get_metadata_and_previews,
                               :edit_metadata_and_relations,
                               :edit_permissions],
                        group: [:get_metadata_and_previews,
                                :edit_metadata_and_relations],
                        api_client: [:get_metadata_and_previews,
                                     :edit_metadata_and_relations],
                        public: [:get_metadata_and_previews] } }.freeze

      def batch_edit_entry_permissions
        batch_edit_resource_permissions(MediaEntry.unscoped)
      end

      def batch_update_entry_permissions
        batch_update_resource_permissions(MediaEntry.unscoped)
      end

      def batch_edit_collection_permissions
        batch_edit_resource_permissions(Collection)
      end

      def batch_update_collection_permissions
        batch_update_resource_permissions(Collection)
      end

      private

      def batch_edit_resource_permissions(scope)
        auth_authorize User, :logged_in?
        return_to = params.require(:return_to)
        resource_ids = params.require(:id)
        resources = scope.where(id: resource_ids)
        if resources.count < 1
          raise ActionController::ParameterMissing, 'No Resources!'
        end
        authorize_resources_for_permissions_batch_edit!(current_user, resources)

        @get = Presenters::Batch::BatchResourcePermissions.new(
          current_user,
          resources,
          return_to)

        @get.dump

        respond_with(@get, template: 'batch/batch_edit_entry_permissions')
      end

      def batch_update_resource_permissions(scope)
        auth_authorize User, :logged_in?
        return_to = params.require(:return_to)
        resource_ids = params.require(:resource_ids)
        resources = scope.where(id: resource_ids)
        authorize_resources_for_permissions_batch_edit!(current_user, resources)

        # NOTE: params.require(:permissions) contains same data structure
        # as in non-batch case, BUT:
        # permission names (keys) that are not mentioned should not be changed!

        batch_update_permissions_transaction!(resources,
                                              params.require(:permissions))
        batch_log_into_edit_sessions! resources
        respond_to do |format|
          format.json do
            flash[:success] = I18n.t(:permissions_batch_success)
            render(json: { forward_url: return_to })
          end
        end
      end

      def batch_update_permissions_transaction!(resources, permissions_data)
        ActiveRecord::Base.transaction do
          resources.each do |resource|
            user_permissions = permissions_data[:user_permissions].to_a
            group_permissions = permissions_data[:group_permissions].to_a
            api_client_permissions = permissions_data[:api_client_permissions].to_a

            # USER PERMISSIONS ####################################################
            create_or_update_user_permissions_for_resource!(resource,
                                                            user_permissions)
            destroy_user_permissions_for_resource!(resource, user_permissions)

            # GROUP PERMISSIONS ###################################################
            create_or_update_group_permissions_for_resource!(resource,
                                                             group_permissions)
            destroy_group_permissions_for_resource!(resource, group_permissions)

            # API CLIENT PERMISSIONS ##############################################
            create_or_update_api_client_permissions_for_resource! \
              resource,
              api_client_permissions
            destroy_api_client_permissions_for_resource!(resource,
                                                         api_client_permissions)

            # PUBLIC PERMISSION ###################################################
            update_public_permission!(resource,
                                      permissions_data[:public_permission])
          end
        end
      end

      def update_public_permission!(resource, public_permission)
        resource.update_attributes! \
          sanitize_attributes public_permission, resource.class, :public
      end

      def destroy_user_permissions_for_resource!(resource, user_permissions)
        subject_ids = user_permissions.map { |p| p[:subject] }
        resource.user_permissions
          .where.not(user_id: subject_ids)
          .or(resource.user_permissions.where.not(delegation_id: subject_ids))
          .each(&:destroy!)
      end

      def destroy_group_permissions_for_resource!(resource, group_permissions)
        resource.group_permissions
          .where.not(group_id: group_permissions.map { |p| p[:subject] })
          .each(&:destroy!)
      end

      def destroy_api_client_permissions_for_resource!(resource,
                                                       api_client_permissions)
        resource.api_client_permissions
          .where.not(api_client_id: api_client_permissions.map { |p| p[:subject] })
          .each(&:destroy!)
      end

      def create_or_update_user_permissions_for_resource!(resource,
                                                          user_permissions)
        user_permissions.each do |p_data|
          sanitized_attributes = \
            sanitize_attributes p_data, resource.class, :user
          next if sanitized_attributes.empty?

          subject_id = p_data[:subject]
          subject_type_id_key =
            if Delegation.find_by_id(subject_id)
              :delegation_id
            elsif User.find_by_id(subject_id)
              :user_id
            else
              raise('Unknown subject type!')
            end

          p = \
            resource
            .user_permissions
            .find_or_create_by! subject_type_id_key => subject_id
          p.update_attributes! sanitized_attributes
        end
      end

      def create_or_update_group_permissions_for_resource!(resource,
                                                           group_permissions)
        group_permissions.each do |p_data|
          sanitized_attributes = \
            sanitize_attributes p_data, resource.class, :group
          next if sanitized_attributes.empty?
          p = \
            resource
            .group_permissions
            .find_or_create_by! group_id: p_data[:subject]
          p.update_attributes! sanitized_attributes
        end
      end

      def create_or_update_api_client_permissions_for_resource!(
        resource,
        api_client_permissions)
        api_client_permissions.each do |p_data|
          sanitized_attributes = \
            sanitize_attributes p_data, resource.class, :api_client
          next if sanitized_attributes.empty?
          p = \
            resource
            .api_client_permissions
            .find_or_create_by! api_client_id: p_data[:subject]
          p.update_attributes! sanitized_attributes
        end
      end

      def sanitize_attributes(p_data, resource_klass, perm_type)
        p_data
          .reject { |k, v| k == :subject }
          .permit SANITIZATION_SPEC[resource_klass.name.to_sym][perm_type]
      end
    end
  end
end
