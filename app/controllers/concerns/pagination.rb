module Concerns
  module Pagination
    extend ActiveSupport::Concern

    included do

      private

      def paginate(resource)
        params[:page] ? resource.page(params[:page]) : resource
      end
    end
  end
end
