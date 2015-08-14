module Concerns
  module CollectionHighlights
    extend ActiveSupport::Concern

    included do
      def edit_highlights
        @collection = Collection.find(params[:id])
        authorize @collection
        @get = \
          Presenters::Collections::ChildMediaResources.new \
            current_user,
            @collection.child_media_resources
        respond_with @get
      end

      def update_highlights
        collection = Collection.find(params[:id])
        authorize collection

        ActiveRecord::Base.transaction do

          media_entry_highlights.each do |h|
            update_highlight(h, Arcs::CollectionMediaEntryArc, :media_entry_id)
          end
          collection_highlights.each do |h|
            update_highlight(h, Arcs::CollectionCollectionArc, :child_id)
          end
          filter_set_highlights.each do |h|
            update_highlight(h, Arcs::CollectionFilterSetArc, :filter_set_id)
          end

        end

        redirect_to collection_path(collection)
      end

      private

      def update_highlight(highlight, arc_klass, assoc_column_name)
        arc_klass
          .find_by!(Hash[assoc_column_name, highlight[:id]])
          .update_attribute(:highlight, highlight[:highlighted])
      end

      def highlights_params
        params.require(:highlights)
      end

      def media_entry_highlights
        highlights_params.select { |h| h[:type] == 'MediaEntry' }
      end

      def collection_highlights
        highlights_params.select { |h| h[:type] == 'Collection' }
      end

      def filter_set_highlights
        highlights_params.select { |h| h[:type] == 'FilterSet' }
      end
    end
  end
end
