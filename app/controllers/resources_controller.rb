# -*- encoding : utf-8 -*-
class ResourcesController < ApplicationController

  def index
    params[:per_page] ||= PER_PAGE.first

    all_ids = ThinkingSphinx.search_for_ids params[:query], {:classes => [MediaEntry, Media::Set], #, Media::Project]
                                                             :per_page => (2**30), :star => true }
    @_resource_ids = all_ids # TODO (all_ids & viewable_ids)
    paginated_ids = @_resource_ids.paginate(:page => params[:page], :per_page => params[:per_page].to_i)
    @json = Logic.data_for_page2(paginated_ids, current_user).to_json
  end

end
