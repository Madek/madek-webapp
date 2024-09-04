module CollectionHighlights
  extend ActiveSupport::Concern
  include ResourceListParams

  included do

    def update_highlights
      collection = Collection.find(params[:id])
      auth_authorize collection

      ActiveRecord::Base.transaction do

        media_entry_highlights.each do |h|
          update_highlight_media_entry(h, collection)
        end
        collection_highlights.each do |h|
          update_highlight_collection(h, collection)
        end

      end

      redirect_to collection_path(collection)
    end

    private

    def update_highlight_media_entry(h, collection)
      update_highlight(
        h,
        Arcs::CollectionMediaEntryArc,
        :media_entry_id,
        :collection_id,
        collection.id)
    end

    def update_highlight_collection(h, collection)
      update_highlight(
        h,
        Arcs::CollectionCollectionArc,
        :child_id,
        :parent_id,
        collection.id)
    end

    def update_highlight(
      hash,
      arc_klass,
      child_column,
      parent_column,
      collection_id)
      arc_klass
        .find_by!(
          child_column => hash[:id],
          parent_column => collection_id
        )
        .update_attribute(:highlight, hash[:selected])
    end

    def highlights_params
      params.require(:resource_selections)
    end

    def media_entry_highlights
      highlights_params.select { |h| h[:type] == 'MediaEntry' }
    end

    def collection_highlights
      highlights_params.select { |h| h[:type] == 'Collection' }
    end

  end
end
