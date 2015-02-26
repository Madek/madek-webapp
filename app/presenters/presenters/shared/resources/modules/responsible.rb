module Presenters
  module Shared
    module Resources
      module Modules
        module Responsible
          def responsible
            @resource.responsible_user.person.to_s
          end
        end
      end
    end
  end
end
