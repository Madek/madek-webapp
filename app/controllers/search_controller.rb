class SearchController < ApplicationController

  # search form
  def show
    skip_authorization
    # render plain: 'index'
  end

  # search result - redirects to filtered index
  def result
    skip_authorization
    filter = build_filter(params)
    redirect_to_filtered_index(filter)
  end

  private

  def build_filter(parameters)
    {}.merge(
      search_filter(parameters)
    ).merge(
      filename_filter(parameters)
    )
  end

  def search_string(parameters)
    parameters.permit(:search).fetch(:search, '')
  end

  def search_filter(parameters)
    if parameters[:search_type] != 'filename'
      {
        search: search_string(parameters)
      }
    else
      {
        search: ''
      }
    end
  end

  def filename_filter(parameters)
    if parameters[:search_type] == 'filename'
      {
        media_files: [
          {
            key: 'filename',
            value: search_string(parameters)
          }
        ]
      }
    else
      {}
    end
  end
end
