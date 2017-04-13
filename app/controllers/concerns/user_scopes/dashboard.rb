module Concerns
  module UserScopes
    module Dashboard
      extend ActiveSupport::Concern

      include Concerns::Clipboard

      # rubocop:disable Metrics/MethodLength
      def build_hash(user)
        {
          unpublished_media_entries: \
            user.unpublished_media_entries,
          content_media_entries: \
            user.responsible_media_entries,
          content_collections: \
            user.responsible_collections,
          content_filter_sets: \
            user.responsible_filter_sets,
          latest_imports: \
            user.created_media_entries,
          favorite_media_entries: \
            user.favorite_media_entries,
          favorite_collections: \
            user.favorite_collections,
          favorite_filter_sets: \
            user.favorite_filter_sets,
          entrusted_media_entries: \
            MediaEntry.entrusted_to_user(user),
          entrusted_collections: \
            Collection.entrusted_to_user(user),
          entrusted_filter_sets: \
            FilterSet.entrusted_to_user(user),
          user_groups: \
            user.groups,
          used_keywords: \
            user
            .used_keywords
            .where(meta_data: { meta_key_id: 'madek_core:keywords' }),

          clipboard: clipboard_collection(user).try(:child_media_resources)
        }
      end
      # rubocop:enable Metrics/MethodLength

      def user_scopes_for_dashboard(user)
        @user_scopes ||= apply_policy_scope_on_hash \
          user,
          build_hash(user)
      end

      def apply_policy_scope_on_hash(user, hash)
        Hash[hash.map { |k, v| [k, v && auth_policy_scope(user, v)] }]
      end
    end
  end
end
