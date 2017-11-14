module Presenters
  module Shared
    module Modules

      module ShowableInAdmin
        extend ActiveSupport::Concern

        included do
          def show_in_admin_button
            {
              id: :show_in_admin_button,
              async_action: nil,
              method: 'get',
              icon: 'admin',
              title: I18n.t(
                :resource_action_show_in_admin,
                raise: false),
              action: resource_path,
              target: :_blank,
              allowed: policy_for(@user).show_in_admin?
            }
          end

          private

          def resource_path
            path_name =
              case type
              when 'MediaEntry' then :admin_entry_path
              when 'Collection' then :admin_collection_path
              end

            send(path_name, @app_resource)
          end
        end

      end
    end
  end
end
