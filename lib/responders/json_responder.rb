module Responders
  module JsonResponder
    def to_json
      obj = if resource.is_a?(Presenter)
              resource.dump
            else
              resource
            end
      render json: obj
    end
  end
end
