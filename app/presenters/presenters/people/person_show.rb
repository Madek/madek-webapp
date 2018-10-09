module Presenters
  module People
    class PersonShow < Presenters::People::PersonCommon
      include AuthorizationSetup

      delegate_to_app_resource \
        :first_name, :last_name, :to_s, \
        :external_uri, :description

      def initialize(app_resource, user, resources_type, list_conf)
        super(app_resource)
        @user = user
        @resources_type = resources_type
        @list_conf = list_conf
      end

      def resources
        type = @resources_type.presence || 'entries'
        klass = resource_class_by_type_string(type)
        user_scope = person_scope(@app_resource, klass)

        resources = Presenters::Shared::MediaResource::MediaResources.new(
          user_scope,
          @user,
          can_filter: true,
          list_conf: @list_conf,
          content_type: content_type
        )

        check_for_try_collection(resources, klass)
        resources
      end

      private

      def content_type
        case @resources_type
        when 'entries' then MediaEntry
        when 'collections' then Collection
        end
      end

      def resource_class_by_type_string(resource_type)
        case resource_type
        when 'entries'
          MediaEntry
        when 'collections'
          Collection
        else
          raise Errors::InvalidParameterValue, "Type is #{type}"
        end
      end

      def media_files_filter?
        return true if @list_conf[:filter].try(:[], :media_files)
      end

      def check_for_try_collection(resources, clazz)
        if !media_files_filter? && resources.empty? && clazz == MediaEntry
          try_scope = person_scope(@app_resource, Collection)
          try_resources = Presenters::Shared::MediaResource::MediaResources.new(
            try_scope,
            @user,
            can_filter: true,
            list_conf: @list_conf,
            content_type: content_type
          )
          if try_resources.any?
            resources.try_collections = true
          end
        end
      end

      def person_scope(person, klass)
        table_name = klass.table_name
        foreign_key = klass.name.foreign_key

        scope = klass.joins(
          <<-SQL
            INNER JOIN meta_data
            ON #{table_name}.id = meta_data.#{foreign_key}
          SQL
        )
        .joins(
          <<-SQL
            LEFT OUTER JOIN meta_data_people
            ON meta_data.id = meta_data_people.meta_datum_id
          SQL
        )
        .joins(
          <<-SQL
            LEFT OUTER JOIN meta_data_roles
            ON meta_data.id = meta_data_roles.meta_datum_id
          SQL
        )
        .where('meta_data_people.person_id = :person_id OR '\
               'meta_data_roles.person_id = :person_id', person_id: person.id)
        .distinct

        auth_policy_scope(@user, scope)
      end
    end
  end
end
