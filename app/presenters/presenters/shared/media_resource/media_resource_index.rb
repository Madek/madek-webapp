module Presenters
  module Shared
    module MediaResource
      class MediaResourceIndex < Presenters::Shared::AppResource
        include Presenters::Shared::MediaResource::Modules::PrivacyStatus

        attr_reader :child_relations
        attr_reader :parent_relations

        def initialize(app_resource, user, list_conf: nil, with_relations: false)
          super(app_resource)
          @user = user
          @list_conf = list_conf
          @with_relations = with_relations
          initialize_relations if with_relations
        end

        private

        def parent_relation_resources
          raise 'Must be implemented be child class.'
        end

        def child_relation_resources
          raise 'Must be implemented be child class.'
        end

        def initialize_relations
          # TODO: reuse exisiting relations presenter
          @parent_relations = nil
          @child_relations = nil
          if parent_relation_resources
            parent_viewable = parent_relation_resources
              .viewable_by_user_or_public(@user)
            @parent_relations = {
              count: parent_viewable.count,
              resources: create_presenter(parent_viewable.limit(2)).resources
            }
          end
          if child_relation_resources
            child_viewable = child_relation_resources
              .viewable_by_user_or_public(@user)
            @child_relations = {
              count: child_viewable.count,
              resources: create_presenter(child_viewable.limit(2)).resources
            }
          end
        end

        def create_presenter(resources)
          Presenters::Shared::MediaResource::IndexResources.new(
            @user,
            resources)
        end

      end
    end
  end
end
