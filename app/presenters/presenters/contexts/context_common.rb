module Presenters
  module Contexts
    class ContextCommon < Presenters::Shared::AppResource

      delegate_to_app_resource(:label, :description)

    end
  end
end
