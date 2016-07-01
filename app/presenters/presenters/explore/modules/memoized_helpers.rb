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
          @catalog_context_keys ||= ContextKey.where(
            context_id: 'upload',
            meta_key_id: @settings.catalog_context_keys
          )
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
            end
        end

        def keywords
          @keywords ||= \
            MetaKey
            .find_by(id: 'madek_core:keywords')
            .try(:keywords)
            .try(:with_usage_count)
            .try(:limit, @limit_keywords)
        end

        ###############################################################
      end
    end
  end
end
