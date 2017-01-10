module Presenters
  module Release
    class ReleaseShow < Presenter

      def version
        MADEK_VERSION[:semver]
      end

      def name
        _release_info[:name]
      end

      def description
        _release_info[:description]
      end

      private

      def _deploy_info
        MADEK_VERSION[:deploy_info]
      end

      def _release_info
        MADEK_VERSION[:release_info]
      end
    end
  end
end
