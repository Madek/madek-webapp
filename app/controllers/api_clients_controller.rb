class ApiClientsController < ApplicationController
  include Concerns::JSONSearch

  def index
    auth_authorize :api_client
    get_and_respond_with_json
  end

end
