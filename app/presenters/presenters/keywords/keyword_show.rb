module Presenters
  module Keywords
    class KeywordShow < Presenters::Keywords::KeywordCommon

      delegate_to_app_resource :description, :external_uri, :rdf_class

      def initialize(user, app_resource, resources_type, list_conf)
        super(app_resource)
        @resources_type = resources_type
        @list_conf = list_conf
        @user = user
      end

      def resources
        type = @resources_type ? @resources_type : 'entries'

        clazz = resource_class_by_type_string(type)

        user_scope = keyword_scope(@app_resource, clazz)

        resources = Presenters::Shared::MediaResource::MediaResources.new(
          user_scope,
          @user,
          can_filter: true,
          list_conf: @list_conf
        )

        check_for_try_collection(resources, clazz)
        resources
      end

      private

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

      def check_for_try_collection(resources, clazz)
        if resources.empty? && clazz == MediaEntry
          try_scope = keyword_scope(@app_resource, Collection)
          try_resources = Presenters::Shared::MediaResource::MediaResources.new(
            try_scope, @user, can_filter: false, list_conf: @list_conf
          )
          if try_resources.any?
            resources.try_collections = true
          end
        end
      end

      def keyword_scope(keyword, clazz)
        classname = clazz.name
        singular = classname.underscore
        plural = singular.pluralize

        scope = clazz.joins(
          <<-SQL
            INNER JOIN meta_data
            ON #{plural}.id = meta_data.#{singular}_id
          SQL
        )
        .joins(
          <<-SQL
            INNER JOIN meta_data_keywords
            ON meta_data.id = meta_data_keywords.meta_datum_id
          SQL
        )
        .where(
          <<-SQL
            meta_data_keywords.keyword_id = '#{keyword.id}'
          SQL
        )
        .distinct

        "#{classname}Policy::Scope".constantize.new(@user, scope).resolve
      end
    end
  end
end
