module Presenters
  module MetaKeys
    class MetaKeyEdit < MetaKeyCommon

      def initialize(app_resource)
        super(app_resource)

        if @app_resource.can_have_keywords?
          keywords = @app_resource.keywords

          # ui should show fixed selection (checkboxes) if less than 16 keywords
          define_singleton_method :show_checkboxes do
            return false if @app_resource.is_extensible_list
            keywords.count <= 16
          end

          # Overrides the subsequent logic which says that only
          # non-extensible are preloaded.
          always_preload = true

          # for non-extensible keywords, include the "first" 50 keywords,
          # used as immediate suggestions (without typing)
          if self.show_checkboxes or !@app_resource.is_extensible_list or always_preload
            define_singleton_method :keywords do
              keywords.limit(50).map do |kw|
                Presenters::Keywords::KeywordIndex.new(kw)
              end
            end
          end
        end

        if @app_resource.id == 'madek_core:copyright_notice'
          define_singleton_method :copyright_notice_templates do
            app_settings.copyright_notice_templates
          end

          define_singleton_method :copyright_notice_default_text do
            app_settings.copyright_notice_default_text
          end
        end
      end

      def roles
        if @app_resource.can_have_roles?
          @app_resource.roles.sorted(I18n.locale).map do |role|
            Presenters::Roles::RoleIndex.new(role)
          end
        end
      end

      private

      def app_settings
        AppSetting.first
      end
    end
  end
end
