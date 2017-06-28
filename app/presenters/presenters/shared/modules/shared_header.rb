module Presenters
  module Shared
    module Modules
      module SharedHeader

        def button_actions
          [
            :edit_button,
            :favor_button,
            :select_collection_button,
            :share_button
          ]
        end

        private

        def shared_edit_button(type, app_resource, user)
          underscore = type.name.underscore

          action = self.send(
            "edit_meta_data_by_context_#{underscore}_path",
            app_resource)

          {
            id: :edit_button,
            async_action: nil,
            method: 'get',
            icon: 'pen',
            title: I18n.t(
              "resource_action_#{underscore}_edit_metadata".to_sym,
              raise: false),
            action: action,
            allowed: policy_for(user).meta_data_update?
          }
        end

        def shared_destroy_button(type, app_resource, user)
          underscore = type.name.underscore

          action = self.send(
            "ask_delete_#{type.name.underscore}_path",
            app_resource)

          {
            id: :destroy_button,
            async_action: nil,
            method: 'get',
            icon: 'trash',
            title: I18n.t(
              "resource_action_#{underscore}_destroy".to_sym,
              raise: false),
            action: action,
            allowed: policy_for(user).destroy?
          }
        end

        def shared_favor_button(type, app_resource, user)
          underscore = type.name.underscore

          title = I18n.t(
            "resource_action_#{underscore}_#{favored ? 'disfavor' : 'favor'}",
            raise: false
          )

          action = self.send(
            "#{favored ? 'disfavor' : 'favor'}_#{underscore}_path",
            app_resource
          )

          allowed = if favored
            policy_for(user).disfavor?
          else
            policy_for(user).favor?
          end

          {
            id: :favor_button,
            async_action: nil,
            method: 'patch',
            icon: favored ? 'favorite' : 'nofavorite',
            title: title,
            action: action,
            allowed: allowed
          }
        end
      end
    end
  end
end
