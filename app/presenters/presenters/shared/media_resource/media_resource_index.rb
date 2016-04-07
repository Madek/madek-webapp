module Presenters
  module Shared
    module MediaResource
      class MediaResourceIndex < Presenters::Shared::AppResource
        include Presenters::Shared::MediaResource::Modules::PrivacyStatus

        attr_reader :child_relations
        attr_reader :parent_relations
        attr_reader :show_relations

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
          if @show_relations
            if parent_relation_resources
              @parent_relations = create_presenter(parent_relation_resources)
            end
            if child_relation_resources
              @child_relations = create_presenter(child_relation_resources)
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
