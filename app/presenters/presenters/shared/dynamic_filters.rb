module Presenters
  module Shared
    # Provides configuration for Filters in UI
    # TODO: usage counts for everything
    # NOTE: since order is important, every filter has a 'position' 0—99,
    #       Vocabularies are always last so their positions start at 100.
    class DynamicFilters < Presenter
      include Presenters::Shared::Modules::VocabularyConfig

      def initialize(user, scope, tree)
        @user = user
        @scope = scope
        @tree = tree || {}
        @resource_type = scope.model or fail 'TypeError! (Expected AR Scope)'
      end

      def all
        [
          media_files(@scope, @tree),
          permissions(@scope, @tree),
          # meta_data(@scope, @tree)
        ].flatten.compact
      end

      private

      # "top-level" sections (just for readabilty):

      def media_files(scope, tree)
        if @resource_type == MediaEntry
          media_files_filters(scope, get_key(tree, :media_files))
        end
      end

      def permissions(scope, tree)
        children = get_key(tree, :permissions)
        permissions_filter(scope, children)
      end

      # helpers

      def media_files_filters(scope, children)
        # FIXME: should filter for document type! (part before slash)
        media_files = scope.map(&:media_file) if children.present?
        file_types = if get_key(children, :content_type)
                       items_from_strings(media_files.map(&:content_type).uniq)
                     end
        extensions = if get_key(children, :extension)
                       items_from_strings(media_files.map(&:extension).uniq)
                     end
        { label: 'Datei',
          uuid: 'media_files',
          position: 1,
          children: [
            { label: 'Medientyp',
              uuid: 'content_type',
              children: file_types },
            { label: 'Dokumenttyp',
              uuid: 'extension',
              children: extensions }] }
      end

      def permissions_filter(scope, children)
        { label: 'Berechtigung',
          uuid: 'permissions',
          position: 2,
          children: children.present? ? nil : [
            permissions_filter_responsible_users(scope, children),
            permissions_filter_entrusted_to_user(scope, children),
            permissions_filter_entrusted_to_group(scope, children),
            permissions_filter_public(scope, children)] }
      end

      def permissions_filter_responsible_users(scope, children)
        users = if get_key(children, :responsible_user)
                  scope.map(&:responsible_user)
                    .uniq
                    .map { |u| Presenters::Users::UserIndex.new(u) }
                end
        { label: 'Verantwortliche Person',
          uuid: 'responsible_user',
          children: users }
      end

      def permissions_filter_entrusted_to_user(scope, children)
        users = if get_key(children, :entrusted_to_user)
                  permission_subjects(scope, :user, :get_metadata_and_previews)
                end
        { label: 'Sichtbar für Person',
          uuid: 'entrusted_to_user',
          multi: true,
          children: users }
      end

      def permissions_filter_entrusted_to_group(scope, children)
        groups = if get_key(children, :entrusted_to_group)
                   permission_subjects(scope, :group, :get_metadata_and_previews)
                 end
        { label: 'Sichtbar für Gruppe',
          multi: true,
          uuid: 'entrusted_to_group',
          children: groups }
      end

      def permissions_filter_public(_scope, children)
        # FIXME: use scope, children; do usage count…
        bools = if get_key(children, :public)
                  [
                    { label: 'Öffentlich', uuid: true },
                    { label: 'Nicht öffentlich', uuid: false }]
                end
        { label: 'Öffentlicher Zugriff',
          uuid: 'public',
          children: bools }
      end

      def permission_subjects(scope, type, action)
        # TODO: usage count
        klass = type.to_s.capitalize
        permision = "Permissions::MediaEntry#{klass}Permission".constantize
        presenter = "Presenters::#{klass.pluralize}::#{klass}Index".constantize
        scope
          .map { |e| permision.where(action => true).where(media_entry: e) }
          .flatten.compact
          .map(&type)
          .uniq
          .map { |s| presenter.new(s) }
      end

      def items_from_strings(list)
        list.map { |str| { uuid: str } }
      end

      def get_key(children, key)
        children.try(:fetch, key, false)
      end
    end
  end
end
