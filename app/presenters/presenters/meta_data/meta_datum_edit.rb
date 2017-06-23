module Presenters
  module MetaData
    class MetaDatumEdit < Presenters::MetaData::MetaDatumCommon

      def initialize(app_resource, user)
        super(app_resource, user)

        # props for special types:
        meta_key = @app_resource.meta_key
        if meta_key.can_have_keywords?
          keywords = meta_key.keywords

          # ui should show fixed selection (checkboxes) if less than 16 keywords
          define_singleton_method :show_checkboxes do
            return false if meta_key.is_extensible_list
            keywords.count <= 16
          end

          # Overrides the subseqiemt logic which says that only
          # non-extensible are preloaded.
          always_preload = true

          # for non-extensible keywords, include the "first" 50 keywords,
          # used as immediate suggestions (without typing)
          if self.show_checkboxes or !meta_key.is_extensible_list or always_preload
            define_singleton_method :keywords do
              keywords.limit(50).map do |kw|
                Presenters::Keywords::KeywordIndex.new(kw)
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
