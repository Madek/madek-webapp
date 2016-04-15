module Responders
  module JsonResponder
    def to_json
      # NOTE: supports "sparse" request via JSON (to optimize async calls)
      obj = if resource.is_a?(Presenter)
              resource.dump(sparse_spec: sparse_request_spec_from_param)
            else
              resource
            end
      render json: obj
    end

    private

    def sparse_request_spec_from_param
      begin
        param = request.params['___sparse']
        JSON.parse(param) if param
      rescue
        nil
      end
    end

  end
end
