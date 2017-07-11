module Presenters
  module Users
    class DashboardSection < Presenter

      attr_reader :section_content, :sections, :section, :clipboard_id

      def initialize(section_content, sections, section, clipboard_id: nil)
        @section_content = section_content
        @sections = sections
        @section = section
        @clipboard_id = clipboard_id
      end
    end
  end
end
