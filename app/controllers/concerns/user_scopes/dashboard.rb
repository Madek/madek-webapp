module Concerns
  module UserScopes
    module Dashboard
      extend ActiveSupport::Concern

      # rubocop:disable Metrics/MethodLength
      def user_scopes_for_dashboard(user)
        @user_scopes ||= apply_policy_scope_on_hash \
          unpublished_media_entries: \
            user.unpublished_media_entries,
          content_media_entries: \
            user.published_media_entries,
          content_collections: \
            user.collections,
          content_filter_sets: \
            user.filter_sets,
          latest_imports: \
            user.published_media_entries,
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
            user.used_keywords
      end
      # rubocop:enable Metrics/MethodLength

      def apply_policy_scope_on_hash(hash)
        Hash[hash.map { |k, v| [k, policy_scope(v)] }]
      end
    end
  end
end