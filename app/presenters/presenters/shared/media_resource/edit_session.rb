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
            @edit_session.created_at
              .in_time_zone(AppSetting.first.time_zone)
              .strftime('%d.%m.%Y, %H:%M')
          end
        end

        def change_date_iso
          @edit_session.created_at.iso8601
        end

        def user
          if @edit_session.user
            Presenters::Users::UserIndex.new(@edit_session.user)
          end
        end
      end
    end
  end
end
