class KeywordTermsController < ApplicationController
  include Concerns::JSONSearch

  def index
    get_and_respond_with_json
  end

end
