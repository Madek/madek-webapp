module WorkflowLocker
  module CommonPermissions
    private

    def apply_common_permissions
      destroy_all_permissions(@workflow.master_collection)
      update_responsible!(@workflow.master_collection)
      update_write_permissions!(@workflow.master_collection)
      update_read_permissions!(@workflow.master_collection)
      update_public_permissions!(@workflow.master_collection)

      nested_resources.each do |resource|
        destroy_all_permissions(resource.cast_to_type)
        update_responsible!(resource.cast_to_type)
        update_write_permissions!(resource.cast_to_type)
        update_read_permissions!(resource.cast_to_type)
        update_public_permissions!(resource.cast_to_type)
      end
    end

    def resource_permissions(resource, scope)
      raise ArgumentError, 'scope must be a Symbol' unless scope.is_a?(Symbol)

      available_permissions =
        case resource
        when Collection
          %i(get_metadata_and_previews edit_metadata_and_relations edit_permissions)
        when MediaEntry
          %i(get_metadata_and_previews get_full_size edit_metadata edit_permissions)
        end

      index =
        case resource
        when Collection then 0
        when MediaEntry then 1
        end

      number_of_applicable_permissions = { # [_if_collection_, _if_media_entry_]
        responsible: [2, 3],
        write: [2, 3],
        read: [1, 1]
      }.fetch(scope)[index]

      {}.tap do |result|
        available_permissions.first(number_of_applicable_permissions).map do |perm_name|
          result[perm_name] = true
        end
      end
    end

    def user_permissions_params(resource, scope)
      configuration['common_permissions'][scope.to_s]
        .select { |o| o['type'] == 'User' }
        .map do |u|
          { user_id: u.is_a?(Hash) ? u.fetch('uuid') : u }
            .merge(resource_permissions(resource, scope))
      end
    end

    def update_responsible!(resource)
      responsible_id = configuration['common_permissions']['responsible']
      resource.reload
      if (user = User.find_by(id: responsible_id))
        resource.update!(responsible_delegation: nil, responsible_user: user)
      elsif (delegation = Delegation.find_by(id: responsible_id))
        resource.update!(responsible_delegation: delegation, responsible_user: nil)
      end
    end

    def group_permissions_params(resource, scope)
      configuration['common_permissions'][scope.to_s]
        .select { |o| ['Group', 'InstitutionalGroup'].include?(o['type']) }
        .map do |g|
          { group_id: g.fetch('uuid') }
            .merge(resource_permissions(resource, scope))
      end
    end

    def update_write_permissions!(resource, scope = :write)
      user_permissions_params(resource, scope)
        .each { |p| resource.user_permissions.create! p }
      group_permissions_params(resource, scope)
        .each { |p| resource.group_permissions.create! p }
    end

    def api_client_permissions_params(resource)
      configuration['common_permissions']['read']
        .select { |o| o['type'] == 'ApiClient' }
        .map do |api_client|
          { api_client_id: api_client.fetch('uuid') }
            .merge(resource_permissions(resource, :read))
      end
    end

    def update_read_permissions!(resource)
      update_write_permissions!(resource, :read)

      api_client_permissions_params(resource)
        .each { |p| resource.api_client_permissions.create! p }
    end

    def update_public_permissions!(resource)
      value = configuration['common_permissions']['read_public']

      case resource
      when Collection
        resource.update!(get_metadata_and_previews: value)
      when MediaEntry
        resource
          .reload # to get access to 'get_full_size' attr
          .update!(get_metadata_and_previews: value, get_full_size: value)
      end
    end

    def destroy_all_permissions(resource)
      resource.user_permissions.destroy_all
      resource.group_permissions.destroy_all
      resource.api_client_permissions.destroy_all
    end
  end
end
