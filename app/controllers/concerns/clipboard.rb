module Clipboard
  extend ActiveSupport::Concern

  def clipboard_collection(user)
    Collection.unscoped.where(clipboard_user_id: user.id).first
  end
end
