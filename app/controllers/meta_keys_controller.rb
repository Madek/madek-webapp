class MetaKeysController < ApplicationController
  include Concerns::JSONSearch

  def index
    auth_authorize :meta_key
    get_and_respond_with_json
  end
end
