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

      def permissions_edit?
        logged_in? and user.can_edit_permissions_for?(record)
      end

      def permissions_update?
        permissions_edit?
      end
    end
  end
end
