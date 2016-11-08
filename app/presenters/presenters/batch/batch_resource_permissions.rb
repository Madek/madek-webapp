# NOTE: very simple version, basically an array of non-batch presenters…

module Presenters
  module Batch
    class BatchResourcePermissions < Presenter

      def initialize(user, resources, return_to)
        @user = user
        @resources = resources
        @return_to = return_to
        unless [MediaEntry, Collection].include?(@resources.model)
          fail TypeError
        end
        @type = @resources.model.name
      end

      # needed to show the resources box:
      def batch_resources
        Presenters::Shared::MediaResource::IndexResources.new(@user, @resources)
      end

      # batch data to be edited:
      def batch_permissions
        pres = "Presenters::#{@type.pluralize}::#{@type}Permissions".constantize
        @resources.map do |resource|
          pres.new(resource, @user)
        end
      end

      def actions
        klass = @resources.model.name.pluralize.underscore
        url = self.send("batch_update_permissions_#{klass}_path")
        {
          save: {
            url: prepend_url_context(url),
            method: 'PUT'
          },
          cancel: { url: @return_to }
        }
      end

    end
  end
end
