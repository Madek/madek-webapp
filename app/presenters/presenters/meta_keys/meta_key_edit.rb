module Presenters
  module MetaKeys
    class MetaKeyEdit < MetaKeyCommon

      def initialize(app_resource)
        super(app_resource)

        meta_key = app_resource
        if meta_key.can_have_keywords?
          keywords = meta_key.keywords

          # ui should show fixed selection (checkboxes) if less than 16 keywords
          define_singleton_method :show_checkboxes do
            return false if meta_key.is_extensible_list
            keywords.count <= 16
          end

          # Overrides the subsequent logic which says that only
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

      def roles
        if @app_resource.can_have_roles?
          Role.sorted(I18n.locale).map do |role|
            Presenters::Roles::RoleIndex.new(role)
          end
        end
      end
    end
  end
end
