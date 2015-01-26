module Concerns
  module Filters
    extend ActiveSupport::Concern

    included do

      private

      def filter_by_param_or_return_unchanged(resource,
                                              scope,
                                              param,
                                              value)
        if param == value
          resource.send(scope, current_user)
        else
          resource
        end
      end

      def filter_by_responsible(resource)
        filter_by_param_or_return_unchanged \
          resource, :in_responsibility_of,
          params[:responsible], 'true'
      end

      def filter_by_favorite(resource)
        filter_by_param_or_return_unchanged \
          resource, :favored_by,
          params[:favorite], 'true'
      end

      def filter_by_entrusted(resource)
        filter_by_param_or_return_unchanged \
          resource, :entrusted_to_user,
          params[:entrusted], 'true'
      end
    end
  end
end
