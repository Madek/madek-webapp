module Features
  module Filter
    module Shared

      def open_filter
        expect(page).to have_selector ".ui-resource"
        find("#ui-side-filter-toggle").click if all("#ui-side-filter-toggle.active").size == 0
        expect(page).to have_selector ".ui-side-filter-item"
      end

    end
  end
end
