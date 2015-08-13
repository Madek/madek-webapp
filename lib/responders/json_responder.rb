module Responders
  module JsonResponder
    def to_json
      render json: (resource.is_a?(Presenter) ? resource.dump : resource).to_json
    end
  end
end
