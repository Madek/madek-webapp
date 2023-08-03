module Presenters
  module Shared
    module MediaResource
      module Modules
        module Responsible
          def responsible
            return unless policy_for(@user).responsible?

            entity = (@app_resource&.responsible_user || @app_resource&.responsible_delegation)
            return unless entity

            if entity.instance_of?(User)
              if entity.is_deactivated
                ::Presenters::Users::UserIndex.new(entity)
              else
                ::Presenters::People::PersonIndex.new(entity.person)
              end
            elsif entity.instance_of?(Delegation)
              ::Presenters::Delegations::DelegationIndex.new(entity)
            end
          end
        end
      end
    end
  end
end
