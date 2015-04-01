module Presenters
  module Shared
    class AppResource < Presenter
      def initialize(app_resource)
        @app_resource = app_resource
      end

      def uuid
        @app_resource.id
      end

      def self.delegate_to_app_resource(*args)
        args.each { |m| delegate m, to: :@app_resource }
      end
    end
  end
end
