module Presenters
  module Shared
    class AppResource < Presenter
      def initialize(app_resource)
        @app_resource = app_resource
      end

      def uuid
        @app_resource.id
      end

      def type
        @app_resource.class.name or super
      end

      def policy(user)
        Pundit.policy!(user, @app_resource)
      end

      # TODO: don't "export" this method, only fail when called
      # def url
      #   throw NotImplementedError, 'missing #url for ' + @app_resource.class.name
      # end

      def self.delegate_to_app_resource(*args)
        delegate_to :@app_resource, *args
      end
    end
  end
end
