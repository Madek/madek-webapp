module Presenters
  module Explore
    module Modules
      module MemoizedHelpers

        private

        ###############################################################
        # memoized helpers used in navigation module as well as the
        # respective section modules.

        def catalog_context_keys
          # NOTE: limit (of catalog_keys) would be 3, for full page ???
          @catalog_context_keys ||= \
            @settings
            .catalog_context_keys
            .try(:take, @limit_catalog_context_keys || 100)
            .try(:map, & proc { |ck_id| ContextKey.find_by_id(ck_id) })
            .to_a
            .compact
        end

        def featured_set_content
          @featured_set_content ||= \
            begin
              unless (feat = @settings.featured_set_id.presence)
                return
              end
              unless (set = Collection.find_by_id(feat))
                return
              end

              ::Shared::MediaResources::MediaResourcePolicy::Scope.new(
                @user, set.child_media_resources)
              .resolve
              .limit(@limit_featured_set)
            end
        end

        def keywords
          @keywords ||= \
            MetaKey
            .find_by(id: 'madek_core:keywords')
            .try(:keywords)
            .try(:limit, @limit_keywords)
        end

        ###############################################################
      end
    end
  end
end
