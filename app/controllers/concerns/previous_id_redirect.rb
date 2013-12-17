module Concerns
  module PreviousIdRedirect
    extend ActiveSupport::Concern
    included do 
      before_filter only: [:show] do
        if (id = params[:id]) and (not id.blank?) and (id =~ /^\d+$/)
          if mr = MediaResource.find_by(previous_id: id)
            redirect_to media_resource_path(mr.id), status: 301
            return
          end
        end
      end
    end
  end
end
