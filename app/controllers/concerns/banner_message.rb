module BannerMessage
  extend ActiveSupport::Concern

  included do
    before_action do
      if current_user && banner_message = localize(settings.banner_messages).presence
        flash.now[:warning] = banner_message
      end
    end
  end
end
