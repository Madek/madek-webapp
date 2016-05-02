class LicensesController < ApplicationController
  include Concerns::JSONSearch

  def index
    get_and_respond_with_json
  end

  def show
    license = get_authorized_resource
    redirect_to_filtered_index(
      meta_data: [{ key: 'any', value: license.id, type: 'MetaDatum::Licenses' }])
  end

end
