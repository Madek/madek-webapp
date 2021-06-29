module Presenters
  module Shared
    class AppResource < Presenter
      include AuthorizationSetup

      def initialize(app_resource)
        fail 'TypeError!' unless app_resource.is_a?(ActiveRecord::Base)
        @app_resource = app_resource.try(:cast_to_type) || app_resource
      end

      # extend presenter base method:
      def type
        @app_resource.class.name or super
      end

      def uuid
        @app_resource.try(:id)
      end

      def created_at
        @app_resource.try(:created_at)
      end

      def updated_at
        @app_resource.try(:updated_at)
      end

      def self.delegate_to_app_resource(*args, as_private_method: false)
        delegate_to :@app_resource, *args
        private *args if as_private_method
      end

      def policy_for(user)
        raise TypeError, 'Not a User!' unless (user.nil? or user.is_a?(User))
        auth_policy(user, @app_resource)
      end

    end
  end
end
