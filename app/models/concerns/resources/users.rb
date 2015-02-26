module Concerns
  module Users
    extend ActiveSupport::Concern

    include Concerns::Users::Creator
    include Concerns::Users::Responsible
  end
end
