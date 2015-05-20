module Responders
  module YamlResponder
    def to_yaml
      render \
        plain: \
          resource \
            .tap { |r| r.dump if r.is_a? Presenter }
            .as_json
            .to_yaml(line_width: -1)
    end
  end
end
