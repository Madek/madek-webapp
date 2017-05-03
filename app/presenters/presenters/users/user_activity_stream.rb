# rubocop:disable Metrics/ClassLength
module Presenters
  module Users
    class UserActivityStream < Presenter
      LIMIT = 100

      def initialize(user, start_date:, end_date:)
        fail 'TypeError!' unless user.is_a?(User)
        fail ArgumentError, 'end must be before start' if end_date > start_date
        @user = user
        @start_date = start_date
        @end_date = end_date
      end

      def current_user
        presenterify_by_class(@user)
      end

      # every method in here returns an array of `"activity" objects`
      # `activity_item: {date, type, object, subject, [details]}`
      # for display, all array are joined and sorted by date.

      # IDEA: if this were run not for a particular user, but for ALL,
      # it would be "global" newsfeed (but needs to take into accout permissions).
      # Also, could possibly provide a stream for all users in a group?

      # TODO: split in 2, 1 per class??? or `join` queries?
      def created_contents
        # including drafts!!!
        entries = time_range_query(UserActivityStream.created_entries(@user))

        sets = time_range_query(UserActivityStream.created_collections(@user))

        (entries + sets).sort_by(&:created_at).reverse.map do |resource|
          activity_item(
            type: 'create', object: resource,
            subject: @user, date: resource.created_at)
        end
      end

      def edited_contents
        time_range_query(UserActivityStream.edits(@user)).map do |es|
          # NOTE: ignores FilterSet
          resource = es.collection \
            || MediaEntry.unscoped.find_by_id(es.media_entry_id)
          next unless resource

          activity_item(
            type: 'edit', object: resource, subject: @user, date: es.created_at)
        end.compact
      end

      def shared_contents
        e = time_range_query(UserActivityStream.shared_entries(@user))
        s = time_range_query(UserActivityStream.shared_collections(@user))

        (e + s).sort_by(&:created_at).reverse
          .map(&method(:sharing_activity_from_permission))
      end

      def url
        # give the url with the used dates so client can use it for info
        prepend_url_context(
          my_dashboard_section_path(
            :activity_stream,
            stream: { from: @start_date.to_i, to: @end_date.to_i }))
      end

      # NOTE: helper for parent to find the initial start of the feed
      #       duplicating the items is the easiest way right now
      #       to get the "first" of all the combined sub-queries
      def self.latest_activity_date(user, start)
        [
          self.created_entries(user), self.created_collections(user),
          self.edits(user),
          self.shared_entries(user), self.shared_collections(user)
        ].map do |scope|
          scope
            .where('created_at <= ?', start)
            .reorder('created_at DESC').first.try(:created_at)
        end
          .compact.sort.last
      end

      # NOTE: those are just class methods because I didn't know better…
      def self.created_entries(user)
        MediaEntry.unscoped.where(creator: user)
      end

      def self.created_collections(user)
        Collection.where(creator: user)
      end

      def self.edits(user)
        EditSession.where(user: user)
      end

      def self.shared_entries(user)
        Permissions::MediaEntryUserPermission
          .where(user: user).reorder('created_at DESC')
      end

      def self.shared_collections(user)
        Permissions::CollectionUserPermission
          .where(user: user).reorder('created_at DESC')
      end

      private

      def sharing_activity_from_permission(perm)
        if perm.class.name.demodulize =~ /Collection/
          resource = perm.collection
          activity_details = permission_activity_details_collection
        else
          resource = perm.media_entry
          activity_details = permission_activity_details_entry
        end

        activity_item(
          type: 'share',
          object: resource,
          subject: perm.updator,
          details: activity_details.map { |d| d[0] if perm[d[1]] }.compact,
          date: perm.created_at)
      end

      def permission_activity_details_entry
        {
          view: 'get_metadata_and_previews',
          download: 'get_full_size',
          edit: 'edit_metadata',
          manage: 'edit_permissions'
        }
      end

      def permission_activity_details_collection
        {
          view: 'get_metadata_and_previews',
          edit: 'edit_metadata_and_relations',
          manage: 'edit_permissions'
        }
      end

      def activity_item(type:, object:, subject:, date:, details: nil)
        raise ArgumentError, 'missing `type`!' unless type.present?
        raise ArgumentError, "#{type}: missing `object`!" unless object.present?
        # allow empty subject for 'share', for v2 permissions we don't know
        unless subject.present? || type == 'share'
          raise ArgumentError, '`subject`!'
        end
        unless date.is_a?(ActiveSupport::TimeWithZone)
          raise ArgumentError, '`date`!'
        end

        object_p = presenterify_by_class(object, @user)
        # NOTE: for performance, cherry-pick minimal props:
        props_per_type = {
          MediaEntry => { title: {}, url: {}, type: {} },
          Collection => { title: {}, url: {}, type: {} }
        }
        if (props_per_type[object.class])
          object_p = object_p.dump(sparse_spec: props_per_type[object.class])
        end

        {
          type: type,
          object: object_p,
          subject: subject ? presenterify_by_class(subject) : nil,
          details: details,
          date: date
        }
      end

      def presenterify_by_class(resource, *args)
        raise ArgumentError unless resource.present?
        presenter_by_class(resource.class).new(resource, *args)
      end

      def presenter_by_class(klass)
        presenter = "Presenters::#{klass.name.pluralize}::#{klass.name}Index"
        begin
          presenter.constantize
        rescue
          raise "No Presenter found! `#{presenter}`"
        end
      end

      def time_range_query(scope, start_date: @start_date, end_date: @end_date)
        throw TypeError unless scope.is_a? ActiveRecord::Relation
        scope = scope.where('created_at >= ?', end_date)
        scope = scope.where('created_at <= ?', start_date) if start_date.present?
        scope
      end

    end
  end
end
