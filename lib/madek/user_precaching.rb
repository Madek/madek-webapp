module Madek
  module UserPrecaching

    # The point of this is to keep some user related data in the database,
    # filesystem and storage cache by simply requesting it.
    #
    # This is very primitive. It can also easily get out of sync
    # with the dashboard controller.
    #
    # TODO: improve and make it less brittle
    #
    # The dashboard must get a refactoring before we can do more and
    # better here.

    class << self
      include Pundit
      include Concerns::UserScopes::Dashboard

      def current_user
        @user
      end

      def section_presenter(user)
        @user = user
        Presenters::Users::UserDashboard.new(
          user, user_scopes_for_dashboard(user),
          nil, with_count: false,
               list_conf: { page: 1, per_page: 1 }
        )
      end

      def pre_cache_user_data(user)
        begin
          section_presenter(user).dump
          Rails.logger.info "Cached data for #{user.login}"
        rescue Exception => e
          Rails.logger.warn e
        end
      end

      def start_pre_caching_loop
        if RUBY_PLATFORM == 'java' && Rails.env == 'production'

          unless $precaching_initialized
            $precaching_initialized = true
            Thread.new do
              Rails.logger.info 'Precaching loop starting in 90 seconds'
              sleep 90
              loop do
                User.where('last_signed_in_at IS NOT NULL') \
                  .reorder(last_signed_in_at: :DESC).limit(100).map do |user|
                  pre_cache_user_data user
                  sleep 10
                end
                sleep 10
              end
            end
          end
        end
      end
    end
  end
end
