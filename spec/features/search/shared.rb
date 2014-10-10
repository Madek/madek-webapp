module Features
  module Search
    module Shared

      def create_a_media_entry
        FactoryGirl.create :media_entry_with_image_media_file, 
          user: @current_user
      end

      def set_media_resource_title media_resource , title
        media_resource.meta_data \
          .create meta_key: MetaKey.find_by_id(:title), value: title
      end

      def check_equality_of_resources_and_result_counters
        expect( find("#resources_counter").text.to_i ).to be == find("#result_count").text.to_i
      end

      def check_number_of_displayed_resources
        expect(page).to have_selector "li.ui-resource"
        expect(all("li.ui-resource").count).to eq find("#result_count").text.to_i
      end

    end
  end
end
