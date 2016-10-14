module Presenters
  module Shared
    module MediaResource
      module Modules
        module EditSessions

          def edit_sessions
            @app_resource.edit_sessions.limit(5).map do |edit_session|
              Presenters::Shared::MediaResource::EditSession.new(edit_session)
            end
          end

        end
      end
    end
  end
end
