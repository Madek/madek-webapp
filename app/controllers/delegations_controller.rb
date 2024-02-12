class DelegationsController < ApplicationController
  include Concerns::JSONSearch

  def index
    auth_authorize :delegation
    get_and_respond_with_json
  end
end
