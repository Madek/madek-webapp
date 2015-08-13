module Responders
  module YamlResponder
    def to_yaml # return als plain text because its only for viewing in browser:
      render plain: \
              (resource.is_a?(Presenter) ? resource.dump : resource)
                .as_json
                .to_yaml(line_width: -1)
    end
  end
end
