module Presenters
  module Users
    class Dashboard < Presenter

      attr_reader :user_dashboard, :sections

      def initialize(user_dashboard, sections)
        @user_dashboard = user_dashboard
        @sections = sections
      end

      def url
        my_dashboard_path
      end
    end
  end
end
