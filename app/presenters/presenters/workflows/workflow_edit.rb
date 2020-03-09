module Presenters
  module Workflows
    class WorkflowEdit < WorkflowCommon
      def creator
        Presenters::Users::UserIndex.new(@app_resource.creator)
      end

      def workflow_owners
        @app_resource.owners.map { |owner| Presenters::Users::UserIndex.new(owner) }
      end

      def common_settings
        { permissions: common_permissions, meta_data: common_meta_data }
      end

      def actions
        {
          upload: { url: new_media_entry_path(workflow_id: @app_resource.id) },
          index: { url: my_workflows_path },
          fill_data: { url: preview_my_workflow_path(@app_resource, fill_data: true) },
          preview: { url: preview_my_workflow_path(@app_resource) },
          update_owners: { url: update_owners_my_workflow_path(@app_resource), method: 'PATCH' }
        }.merge(super)
      end

      def permissions
        {
          can_edit: policy_for(@user).update?,
          can_edit_owners: policy_for(@user).update_owners?,
          can_preview: policy_for(@user).preview?
        }
      end

      private

      def role_presenter(value)
        md_role =
          MetaDatum::Role.new(
            person: Person.find_by(id: value['uuid']), role: Role.find_by(id: value['role'])
          )
        Presenters::People::PersonIndexForRoles.new(md_role)
      end

      def md_presenter(klass, uuid)
        "Presenters::#{klass}::#{klass.singularize}Index".constantize.new(
          klass.singularize.constantize.find(uuid)
        )
      end

      def role_is_not_presenterified?(value)
        !value.key?('uuid') && value['role'].present? &&
          !value['role'].is_a?(Presenters::Roles::RoleIndex)
      end

      def meta_data_value(value, meta_key)
        return [] unless value.present?
        type = meta_key.meta_datum_object_type
        value.map do |val|
          uuid = val['uuid']

          return '' if val.is_a?(Hash) && val.empty? # TODO: remove?
          if val.is_a?(String)
            { string: val }
          elsif role_is_not_presenterified?(val)
            val['role'] = Presenters::Roles::RoleIndex.new(Role.find(val['role']))
            val
          elsif UUIDTools::UUID_REGEXP =~ uuid
            klass = type.split('::').last
            klass == 'Roles' ? role_presenter(val) : md_presenter(klass, uuid)
          else
            val
          end
        end
      end

      def common_meta_data
        @app_resource.configuration['common_meta_data'].map do |md|
          begin
            # build something like MetaDatumEdit presenter, but from plain JSON
            meta_key = MetaKey.find(md['meta_key_id'])
            mk = Presenters::MetaKeys::MetaKeyEdit.new(meta_key)
          rescue ActiveRecord::RecordNotFound
            next
          end

          { meta_key: mk, value: meta_data_value(md['value'], meta_key) }.merge(
            md.slice('is_common', 'is_mandatory', 'is_overridable')
          )
        end
      end
    end
  end
end
