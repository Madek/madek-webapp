module UserScopes
  module Dashboard
    extend ActiveSupport::Concern

    include Clipboard

    def build_hash(user)
      exclude_auth_groups_cond = Group.arel_table[:type].not_eq('AuthenticationGroup')

      {
        unpublished_media_entries: \
          user.unpublished_media_entries,
        content_media_entries: \
          user.responsible_media_entries,
        content_collections: \
          user.responsible_collections,
        content_delegated_media_entries: \
          user.delegated_media_entries,
        content_delegated_collections: \
          user.delegated_collections,
        latest_imports: \
          user.created_media_entries,
        favorite_media_entries: \
          user.favorite_media_entries,
        favorite_collections: \
          user.favorite_collections,
        entrusted_media_entries: \
          MediaEntry.entrusted_to_user(user, add_group_cond: exclude_auth_groups_cond),
        entrusted_collections: \
          Collection.entrusted_to_user(user, add_group_cond: exclude_auth_groups_cond),
        user_groups: user.groups,
        user_delegations: user.all_delegations,
        used_keywords: \
          user
          .used_keywords
          .where(meta_data: { meta_key_id: 'madek_core:keywords' }),

        clipboard: clipboard_collection(user).try(:child_media_resources)
      }
    end

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
