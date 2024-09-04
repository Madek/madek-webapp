class DelegationsController < ApplicationController
  include JSONSearch

  def index
    auth_authorize :delegation
    get_and_respond_with_json
  end
end
