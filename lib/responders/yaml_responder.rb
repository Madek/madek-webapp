module Responders
  module YamlResponder

    def to_yaml
      # - render `plain` text because its only for viewing in browser
      # - `as_json` to stringify all the keys
      render plain: serialize_resource.as_json.to_yaml
    end

  end
end
