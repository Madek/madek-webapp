module Presenters
  module Users
    class DashboardSection < Presenter

      attr_reader :section_resources, :sections, :section

      def initialize(section_resources, sections, section)
        @section_resources = section_resources
        @sections = sections
        @section = section
      end
    end
  end
end
