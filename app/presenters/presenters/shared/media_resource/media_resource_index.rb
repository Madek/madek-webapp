module Presenters
  module Shared
    module MediaResource
      class MediaResourceIndex < Presenters::Shared::AppResource
        include Presenters::Shared::MediaResource::Modules::PrivacyStatus

        attr_reader :child_relations
        attr_reader :parent_relations
        attr_reader :show_relations
        attr_reader :child_count
        attr_reader :parent_count

        def initialize(app_resource, user, list_conf: nil, show_relations: false)
          super(app_resource)
          @user = user
          @list_conf = list_conf
          @show_relations = show_relations
          initialize_relations
        end

        private

        def parent_relation_resources
          raise 'Must be implemented be child class.'
        end

        def child_relation_resources
          raise 'Must be implemented be child class.'
        end

        def initialize_relations
          @parent_relations = nil
          @child_relations = nil
          @parent_count = 0
          @child_count = 0
          if @show_relations
            if parent_relation_resources
              parent_viewable = parent_relation_resources
                .viewable_by_user_or_public(@user)
              @parent_count = parent_viewable.count
              @parent_relations = create_presenter(parent_viewable.limit(2))
            end
            if child_relation_resources
              child_viewable = child_relation_resources
                .viewable_by_user_or_public(@user)
              @child_count = child_viewable.count
              @child_relations = create_presenter(child_viewable.limit(2))
            end
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
