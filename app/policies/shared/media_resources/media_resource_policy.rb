module Shared
  module MediaResources
    class MediaResourcePolicy < ApplicationPolicy
      def show?
        if logged_in?
          record.viewable_by_user?(user)
        else
          record.viewable_by_public?
        end
      end

      def permissions_show?
        show?
      end
    end
  end
end
