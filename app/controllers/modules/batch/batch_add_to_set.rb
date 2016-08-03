module Modules
  module Batch
    module BatchAddToSet
      extend ActiveSupport::Concern

      include Modules::Batch::BatchAuthorization
      include Modules::Batch::BatchShared
      include Modules::Collections::Store

      def batch_select_add_to_set
        presenter_values = presenter_values(params)

        search_term = params[:clear] ? '' : params[:search_term]
        presenter_values[:search_term] = search_term

        @get = Presenters::Batch::BatchAddToSet.new(presenter_values)
        respond_with(@get, template: 'batch/batch_select_add_to_set')
      end

      def batch_add_to_set
        return_to = params.require(:return_to)

        parent_collection_id = prepare_parent_collection(params)

        action_values = action_values(params, parent_collection_id)

        add_transaction(
          action_values[:parent_collection],
          action_values[:media_entries],
          action_values[:collections])

        redirect_to(return_to)
      end

      def prepare_parent_collection(params)
        if params[:parent_collection_id][:new]
          title = params[:parent_collection_id][:new]
          collection = store_collection(title)
          parent_collection_id = collection.id

        elsif params[:parent_collection_id][:existing]
          parent_collection_id = params[:parent_collection_id][:existing]
        else
          raise 'error'
        end
        parent_collection_id
      end

      private

      def add_transaction(parent_collection, media_entries, collections)
        ActiveRecord::Base.transaction do
          existing = parent_collection.media_entries
            .rewhere(is_published: [true, false]).reload
          media_entries.each do |media_entry|
            unless existing.include? media_entry
              parent_collection.media_entries << media_entry
            end
          end
          existing = parent_collection.collections.reload
          collections.each do |collection|
            unless existing.include? collection
              parent_collection.collections << collection
            end
          end
        end
      end
    end
  end
end
