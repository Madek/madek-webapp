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
          define_singleton_method :fixed_selection do
            count = keywords.count
            count > 0 and count <= 16
          end

          # for non-extensible keywords, include the "first" 50 keywords,
          # used as immediate suggestions (without typing)
          if self.fixed_selection or !meta_key.is_extensible_list
            define_singleton_method :keywords do
              keywords.reorder(:term).limit(50).map do |kw|
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
