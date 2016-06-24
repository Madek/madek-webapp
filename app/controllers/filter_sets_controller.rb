class FilterSetsController < ApplicationController
  include Concerns::MediaResources::CrudActions
  include Concerns::MediaResources::CustomUrlsForController
  include Concerns::MediaResources::PermissionsActions

  ALLOWED_FILTER_PARAMS = [:search].freeze

  def create
    filter, title = create_filter_set_params.values_at(:filter, :title)

    filter_set = FilterSet.create!(
      definition: filter,
      creator: current_user,
      responsible_user: current_user,
      meta_data: [MetaDatum::Text.new(
        meta_key_id: 'madek_core:title',
        string: title,
        created_by: current_user)])

    authorize(filter_set.reload)

    represent(filter_set, Presenters::FilterSets::FilterSetIndex)
  end

  private

  def filter_set_params
    params.require(:filter_set)
  end

  def create_filter_set_params
    {
      title: filter_set_params.require(:title),
      filter: filter_set_params.require(:filter)
    }.deep_symbolize_keys
  end

end
