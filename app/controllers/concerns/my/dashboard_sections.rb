module Concerns
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
        {
          activity_stream: {
            title: 'Aktivitäten',
            icon: 'icon-privacy-private',
            partial: :activity_stream,
            hide_from_index: true
          },
          clipboard: {
            title: I18n.t(:sitemap_clipboard),
            icon: 'icon-privacy-group',
            partial: :media_resources,
            is_beta: true,
            hide_from_index: true
          },
          unpublished_entries: {
            title: I18n.t(:sitemap_my_unpublished),
            icon: 'icon-privacy-private',
            partial: :media_resources,
            allowed_filter_params:
              Concerns::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS
          },
          content_media_entries: {
            title: I18n.t(:sitemap_my_content_media_entries),
            icon: 'icon-privacy-private',
            partial: :media_resources,
            allowed_filter_params:
              Concerns::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS
          },
          content_collections: {
            title: I18n.t(:sitemap_my_content_collections),
            icon: 'icon-privacy-private',
            partial: :media_resources,
            allowed_filter_params:
              Concerns::ResourceListParams::COLLECTIONS_ALLOWED_FILTER_PARAMS
          },
          # content_filter_sets: {
          #   title: I18n.t(:sitemap_my_content_filter_sets),
          #   icon: 'icon-privacy-private',
          #   partial: :media_resources
          # },
          latest_imports: {
            title: I18n.t(:sitemap_my_latest_imports),
            icon: 'icon-privacy-private',
            partial: :media_resources,
            allowed_filter_params:
              Concerns::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS
          },
          favorite_media_entries: {
            title: I18n.t(:sitemap_my_favorite_media_entries),
            icon: 'icon-privacy-private',
            partial: :media_resources,
            allowed_filter_params:
              Concerns::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS
          },
          favorite_collections: {
            title: I18n.t(:sitemap_my_favorite_collections),
            icon: 'icon-privacy-private',
            partial: :media_resources,
            allowed_filter_params:
              Concerns::ResourceListParams::COLLECTIONS_ALLOWED_FILTER_PARAMS
          },
          # favorite_filter_sets: {
          #   title: I18n.t(:sitemap_my_favorite_filter_sets),
          #   icon: 'icon-privacy-private',
          #   partial: :media_resources
          # },
          used_keywords: {
            title: I18n.t(:sitemap_my_used_keywords),
            icon: 'icon-tag',
            partial: :keywords
          },
          entrusted_media_entries: {
            title: I18n.t(:sitemap_my_entrusted_media_entries),
            icon: 'icon-privacy-group',
            partial: :media_resources,
            allowed_filter_params:
              Concerns::ResourceListParams::ENTRIES_ALLOWED_FILTER_PARAMS
          },
          entrusted_collections: {
            title: I18n.t(:sitemap_my_entrusted_collections),
            icon: 'icon-privacy-group',
            partial: :media_resources,
            allowed_filter_params:
              Concerns::ResourceListParams::COLLECTIONS_ALLOWED_FILTER_PARAMS
          },
          # entrusted_filter_sets: {
          #   title: I18n.t(:sitemap_my_entrusted_filter_sets),
          #   icon: 'icon-privacy-group',
          #   partial: :media_resources
          # },
          groups: {
            title: I18n.t(:sitemap_my_groups),
            icon: 'icon-privacy-group',
            partial: :groups
          },
          vocabularies: {
            title: I18n.t(:sitemap_vocabularies),
            icon: 'icon-privacy-group',
            hide_from_index: true,
            href: '/vocabulary' # NOTE: no path helper, this route is fixed
          }
        }.compact
      end
      # rubocop:enable Metrics/MethodLength

    end
  end
end
