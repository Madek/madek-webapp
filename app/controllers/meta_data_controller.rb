class MetaDataController < ApplicationController
  include UuidHelper

  def new
  end

  def create
    media_entry_id, collection_id, filter_set_id, \
      meta_key_id, value, type = params_list

    begin
      meta_datum_klass = type.constantize
      meta_datum_klass.create!(media_entry_id: media_entry_id,
                               collection_id: collection_id,
                               filter_set_id: filter_set_id,
                               meta_key_id: meta_key_id,
                               value: value)
      redirect_to \
        find_resource_by_uuid \
          get_single_uuid(media_entry_id, collection_id, filter_set_id)
    rescue => e
      render(text: e.message, status: :internal_server_error)
      return
    end
  end

  private

  def params_list
    [params[:media_entry_id],
     params[:collection_id],
     params[:filter_set_id],
     params[:_key],
     params[:_value][:content],
     params[:_value][:type]]
  end
end
