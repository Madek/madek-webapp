module Presenters
  module Keywords
    class KeywordAsFilter < Presenters::Keywords::KeywordCommon

      def initialize(app_resource, scope)
        super(app_resource)
        @scope = scope
      end

      # get "usage count" of term by applying it as an additional filter
      # to current scope and counting resulting resources
      # FIXME: correct, but highly inefficient. optimize!
      def count(term = @app_resource, scope = @scope)
        scope
          .filter_by(meta_data: [{ key: term.meta_key_id, value: term.id }])
          .uniq # needed? not sure…
          .count
      end

    end
  end
end
