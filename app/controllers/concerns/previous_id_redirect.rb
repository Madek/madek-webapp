module Concerns
  module PreviousIdRedirect
    extend ActiveSupport::Concern

    included do 
      before_filter only: [:show] do
        if (id = params[:id]) and (not id.blank?) and (id =~ /^\d+$/)
          if mr = MediaResource.find_by(previous_id: id)
            redirect_to media_resource_path(mr.id), status: 301
          end
        end
      end
    end

    def check_for_old_id_and_in_case_redirect_to method_name
      if (id = params[:id]) and (not id.blank?) and (id =~ /^\d+$/)
        if mr = MediaResource.find_by(previous_id: id)
          path= self.send method_name, mr.id
          redirect_to path, status: 301
        end
      end
    end

  end
end
