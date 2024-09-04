class GroupsController < ApplicationController
  include JSONSearch

  def index
    auth_authorize :group
    get_and_respond_with_json
  end
end
