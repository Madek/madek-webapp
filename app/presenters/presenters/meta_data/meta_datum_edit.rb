module Presenters
  module MetaData
    class MetaDatumEdit < Presenters::MetaData::MetaDatumCommon

      def initialize(app_resource, user)
        super(app_resource, user)

        # props for special types:
        if @app_resource.meta_key.can_have_keywords?
          # all the keywords for this key:
          keywords = @app_resource.meta_key.keywords

          # ui should show fixed selection (checkboxes) if less than 16 keywords
          define_singleton_method :fixed_selection do
            count = keywords.count
            count > 0 and count <= 16
          end

          # include possible values for fixed selections
          # TODO: include possible values for non-extensible OR fixed selections
          if self.fixed_selection # or !@meta_key.is_extensible
            define_singleton_method :keywords do
              keywords.map do |kw|
                Presenters::Keywords::KeywordCommon.new(kw)
              end
            end
          end
        end
      end

      def url
        return unless @app_resource.id # new MDs, like for edit, dont have an URL!
        super
      end

    end
  end
end
