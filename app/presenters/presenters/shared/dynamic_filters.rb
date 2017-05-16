module Presenters
  module Shared
    # Provides configuration for Filters in UI
    # TODO: usage counts for everything
    # NOTE: since order is important, every filter has a 'position' 0—99,
    #       Vocabularies are always last so their positions start at 100.
    # NOTE: Context sections are implemented as Presenters,
    # but everything else can't reuse anything. Just build plain hashes.
    class DynamicFilters < Presenter
      include Presenters::Shared::Modules::VocabularyConfig

      def initialize(user, scope, tree)
        @user = user
        @scope = scope
        @tree = tree || {}
        @resource_type = scope.model or fail 'TypeError! (Expected AR Scope)'
        # TMP:
        # unless @resource_type == MediaEntry
        #   fail 'TypeError! (Expected Entry scope)'
        # end
      end

      def list
        [
          # TMP disabled:
          (media_files(@scope, @tree) if @resource_type == MediaEntry),
          # permissions(@scope, @tree),
          meta_data(@scope, @tree)
        ].flatten.compact
      end

      private

      # "top-level" sections (just for readabilty):

      def media_files(scope, tree)
        if @resource_type == MediaEntry
          media_files_filters(scope, get_key(tree, :media_files))
        end
      end

      # def permissions(scope, tree)
      #   children = get_key(tree, :permissions)
      #   permissions_filter(scope, children)
      # end

      def meta_data(scope, _tree)
        # TODO: ui_context_list = contexts_for_dynamic_filters (when in Admin UI)
        ui_context_list = _contexts_for_dynamic_filters # from VocabularyConfig
        return unless ui_context_list.present?
        ui_context_list_ids = ui_context_list.map(&:id)
        values = FilterBarQuery.get_metadata_unsafe(
          @resource_type, scope, ui_context_list, @user)
        values
          .group_by { |v| v['context_id'] }
          .sort_by { |bundle| ui_context_list_ids.index(bundle[0]) }
          .map.with_index do |bundle, index|
            context_id, values = bundle
            # Sort them last in list (assumes there are less than 100 app-filters):
            position = 100 + index
            Presenters::Contexts::ContextAsFilter.new(
              Context.find(context_id), values, position)
          end
      end

      # helpers

      # TMP disabled
      def media_files_filters(scope, _children)
        media_types = FilterBarQuery.get_media_types_unsafe(scope)
        extensions = FilterBarQuery.get_extensions_unsafe(scope)

        if media_types.empty? and extensions.empty?
          return nil
        end

        children = []
        unless media_types.empty?
          children <<
            { label: 'Medientyp',
              uuid: 'media_type',
              children: media_types,
              multi: false }
        end
        unless extensions.empty?
          children <<
            { label: 'Dokumenttyp',
              uuid: 'extension',
              children: extensions,
              multi: false }
        end

        { label: 'Datei',
          filter_type: 'media_files',
          uuid: 'file',
          position: 1,
          children: children }
      end

      # TMP disabled
      # def permissions_filter(scope, children)
      #   { label: 'Berechtigung',
      #     uuid: 'permissions',
      #     position: 2,
      #     children: children.present? ? nil : [
      #       permissions_filter_responsible_users(scope, children),
      #       permissions_filter_entrusted_to_user(scope, children),
      #       permissions_filter_entrusted_to_group(scope, children),
      #       permissions_filter_public(scope, children)] }
      # end
      #
      # def permissions_filter_responsible_users(scope, children)
      #   users = if get_key(children, :responsible_user)
      #             scope.map(&:responsible_user)
      #               .uniq
      #               .map { |u| Presenters::Users::UserIndex.new(u) }
      #           end
      #   { label: 'Verantwortliche Person',
      #     uuid: 'responsible_user',
      #     children: users }
      # end
      #
      # def permissions_filter_entrusted_to_user(scope, children)
      #   users = if get_key(children, :entrusted_to_user)
      #             permission_subjects(scope, :user, :get_metadata_and_previews)
      #           end
      #   { label: 'Sichtbar für Person',
      #     uuid: 'entrusted_to_user',
      #     multi: true,
      #     children: users }
      # end
      #
      # def permissions_filter_entrusted_to_group(scope, children)
      #   groups = if get_key(children, :entrusted_to_group)
      #              permission_subjects(scope, :group, :get_metadata_and_previews)
      #            end
      #   { label: 'Sichtbar für Gruppe',
      #     multi: true,
      #     uuid: 'entrusted_to_group',
      #     children: groups }
      # end
      #
      # def permissions_filter_public(_scope, children)
      #   # FIXME: use scope, children; do usage count…
      #   bools = if get_key(children, :public)
      #             [
      #               { label: 'Öffentlich', uuid: true },
      #               { label: 'Nicht öffentlich', uuid: false }]
      #           end
      #   { label: 'Öffentlicher Zugriff',
      #     uuid: 'public',
      #     children: bools }
      # end
      #
      # def permission_subjects(scope, type, action)
      #   # TODO: usage count
      #   klass = type.to_s.capitalize
      #   permision = "Permissions::MediaEntry#{klass}Permission".constantize
      #   presenter = "Presenters::#{klass.pluralize}::#{klass}Index".constantize
      #   scope
      #     .map { |e| permision.where(action => true).where(media_entry: e) }
      #     .flatten.compact
      #     .map(&type)
      #     .uniq
      #     .map { |s| presenter.new(s) }
      # end
      #
      # def items_from_strings(list)
      #   list.map { |str| { uuid: str } }
      # end
      #
      def get_key(children, key)
        children.try(:fetch, key, false)
      end
    end
  end
end
