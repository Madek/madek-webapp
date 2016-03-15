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

      def created_at
        @app_resource.try(:created_at)
      end

      def updated_at
        @app_resource.try(:updated_at)
      end

      def self.delegate_to_app_resource(*args)
        delegate_to :@app_resource, *args
      end

      def policy(user)
        raise TypeError, 'Not a User!' unless (user.nil? or user.is_a?(User))
        Pundit.policy!(user, @app_resource)
      end

    end
  end
end
