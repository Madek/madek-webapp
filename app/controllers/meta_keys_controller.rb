class MetaKeysController < ApplicationController
  include JSONSearch

  def index
    auth_authorize :meta_key
    get_and_respond_with_json
  end
end
