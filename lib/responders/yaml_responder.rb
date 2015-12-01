module Responders
  module YamlResponder
    def to_yaml
      obj = if resource.is_a?(Presenter)
              resource.dump
            else
              resource
            end
      # - render `plain` text because its only for viewing in browser
      # - `as_json` to stringify all the keys
      render plain: obj.as_json.to_yaml(line_width: -1)
    end
  end
end
