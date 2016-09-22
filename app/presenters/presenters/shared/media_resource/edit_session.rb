module Presenters
  module Shared
    module MediaResource
      class EditSession < Presenter

        def initialize(edit_session)
          @edit_session = edit_session
        end

        def uuid
          @edit_session.id
        end

        def change_date
          if @edit_session.created_at
            @edit_session.created_at.strftime('%d.%m.%Y')
          end
        end

        def user
          if @edit_session.user and @edit_session.user.person
            Presenters::People::PersonIndex.new(@edit_session.user.person)
          end
        end
      end
    end
  end
end
