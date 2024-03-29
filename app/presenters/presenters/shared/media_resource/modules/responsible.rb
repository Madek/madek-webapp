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
              ::Presenters::Users::UserIndex.new(entity)
            elsif entity.instance_of?(Delegation)
              ::Presenters::Delegations::DelegationIndex.new(entity)
            end
          end
        end
      end
    end
  end
end
