module Presenters
  module Release
    class ReleaseShow < Presenter
      include ApplicationHelper

      def version
        MADEK_VERSION[:semver]
      end

      def releases
        (MADEK_VERSION[:releases] || []).map do |r|
          r.merge(description: markdown(r[:description] || ''))
        end.presence
      end

      def deploy_info
        MADEK_VERSION[:deploy_info]
      end

      def dev_info
        return unless MADEK_VERSION[:type] == 'git'
        MADEK_VERSION
      end

    end
  end
end
