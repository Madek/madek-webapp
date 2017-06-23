module Responders
  module JsonResponder

    def to_json
      render json: serialize_resource
    end

  end
end
