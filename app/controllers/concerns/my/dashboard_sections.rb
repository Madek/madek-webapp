module My
  module DashboardSections

    # NOTE: conventions for sections:
    # - if it has `resources`,
    #   UserDashboardPresenter has a method with name of section

    # - `partial` props: used for index and show
    #    - ex: `partial: :foobar` → `section_partial_foobar.haml`
    #    - no `partial` but `href` renders an entry in the sidebar only

    # rubocop:disable Metrics/MethodLength
    def sections_definition
      user_is_member_of_delegations = current_user.all_delegations.any?
      {
        activity_stream: {
          title: I18n.t(:sitemap_activities),
          icon: 'icon-privacy-private',
          partial: :activity_stream,
          hide_from_index: true,
          href: my_dashboard_section_path(:activity_stream)
        },
        notifications: {
          title: I18n.t(:sitemap_notifications),
          fa: 'bell',
          partial: :notifications,
          is_beta: true,
          hide_from_index: true,
          href: my_dashboard_section_path(:notifications),
          is_accessible: current_user.try(:beta_tester_notifications?),
          counter: current_user.notifications.count { |n| !n.acknowledged? }
        },
        workflows: {
          title: 'Workflows',
          fa: 'flask',
          partial: :workflows,
          is_beta: true,
          hide_from_index: true,
          href: my_dashboard_section_path(:workflows),
          is_accessible: policy(:workflow).index?
        },
        clipboard: {
          title: I18n.t(:sitemap_clipboard),
          icon: 'icon-clipboard',
          partial: :media_resources,
          is_beta: true,
          hide_from_index: true,
          href: my_dashboard_section_path(:clipboard)
        },
        unpublished_entries: {
          title: I18n.t(:sitemap_my_unpublished),
          icon: 'icon-pen',
          partial: :media_resources,
          allowed_filter_params:
            ::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS,
          href: my_dashboard_section_path(:unpublished_entries)
        },
        content_media_entries: {
          title: I18n.t(:sitemap_my_content_media_entries),
          section_title: I18n.t(:section_title_media_entries),
          icon: 'icon-media-entry',
          partial: :media_resources,
          allowed_filter_params:
            ::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS,
          href: my_dashboard_section_path(:content_media_entries)
        },
        content_collections: {
          title: I18n.t(:sitemap_my_content_collections),
          section_title: I18n.t(:section_title_collections),
          icon: 'icon-set',
          partial: :media_resources,
          allowed_filter_params:
            ::ResourceListParams::COLLECTIONS_ALLOWED_FILTER_PARAMS,
          href: my_dashboard_section_path(:content_collections)
        },
        content_delegated_media_entries: !user_is_member_of_delegations ? nil : {
          title: I18n.t(:sitemap_my_delegated_media_entries),
          icon: 'icon-media-entry',
          partial: :media_resources,
          allowed_filter_params:
            ::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS,
          href: my_dashboard_section_path(:content_delegated_media_entries)
        },
        content_delegated_collections: !user_is_member_of_delegations ? nil : {
          title: I18n.t(:sitemap_my_delegated_collections),
          icon: 'icon-set',
          partial: :media_resources,
          allowed_filter_params:
            ::ResourceListParams::COLLECTIONS_ALLOWED_FILTER_PARAMS,
          href: my_dashboard_section_path(:content_delegated_collections)
        },
        latest_imports: {
          title: I18n.t(:sitemap_my_latest_imports),
          icon: 'icon-media-entry',
          partial: :media_resources,
          allowed_filter_params:
            ::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS,
          href: my_dashboard_section_path(:latest_imports)
        },
        favorite_media_entries: {
          title: I18n.t(:sitemap_my_favorite_media_entries),
          icon: 'icon-star',
          partial: :media_resources,
          allowed_filter_params:
            ::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS,
          href: my_dashboard_section_path(:favorite_media_entries)
        },
        favorite_collections: {
          title: I18n.t(:sitemap_my_favorite_collections),
          icon: 'icon-star',
          partial: :media_resources,
          allowed_filter_params:
            ::ResourceListParams::COLLECTIONS_ALLOWED_FILTER_PARAMS,
          href: my_dashboard_section_path(:favorite_collections)
        },
        used_keywords: {
          title: I18n.t(:sitemap_my_used_keywords),
          section_title: I18n.t(:section_title_keywords),
          icon: 'icon-tag',
          partial: :keywords,
          href: my_dashboard_section_path(:used_keywords)
        },
        entrusted_media_entries: {
          title: I18n.t(:sitemap_my_entrusted_media_entries),
          icon: 'icon-media-entry',
          partial: :media_resources,
          allowed_filter_params:
            ::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS,
          href: my_dashboard_section_path(:entrusted_media_entries)
        },
        entrusted_collections: {
          title: I18n.t(:sitemap_my_entrusted_collections),
          icon: 'icon-set',
          partial: :media_resources,
          allowed_filter_params:
            ::ResourceListParams::COLLECTIONS_ALLOWED_FILTER_PARAMS,
          href: my_dashboard_section_path(:entrusted_collections)
        },
        groups: {
          title: I18n.t(:sitemap_my_groups),
          icon: 'icon-privacy-group',
          partial: :groups,
          href: my_dashboard_section_path(:groups)
        },
        tokens: {
          title: I18n.t(:sitemap_tokens),
          section_title: I18n.t(:section_title_tokens),
          fa: 'key',
          partial: :tokens,
          is_beta: true,
          hide_from_index: true,
          href: my_dashboard_section_path(:tokens)
        },
        vocabularies: {
          title: I18n.t(:sitemap_vocabularies),
          icon: 'icon-privacy-group',
          hide_from_index: true,
          href: vocabularies_path
        },
        settings: {
          title: I18n.t(:sitemap_settings),
          icon: 'icon-cog',
          partial: :settings,
          is_beta: true,
          hide_from_index: true,
          href: my_dashboard_section_path(:settings),
          is_accessible: current_user.try(:beta_tester_notifications?)
        }
      }.compact
    end
    # rubocop:enable Metrics/MethodLength

  end
end
