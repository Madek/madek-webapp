module Presenters
  module Shared
    class AppResource < Presenter
      def initialize(app_resource)
        fail 'TypeError!' unless app_resource.is_a?(ActiveRecord::Base)
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

      def self.delegate_to_app_resource(*args)
        delegate_to :@app_resource, *args
      end
    end
  end
end
