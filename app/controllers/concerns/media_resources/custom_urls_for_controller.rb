module MediaResources
  module CustomUrlsForController # avoiding name clash with DL
    extend ActiveSupport::Concern
    include CustomUrlId
  end
end
