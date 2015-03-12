class Admin::MetaDatumsController < AdminController
  def index
    @meta_datums = MetaDatum.includes(:meta_key)
                            .page(params[:page])
                            .per(16)

    filter
  end

  private

  def filter
    if (search_term = params[:search_term]).present?
      filter_method = {
        id: :with_id,
        string: :with_string,
        media_entry_id: :of_media_entry,
        collection_id: :of_collection,
        filter_set_id: :of_filter_set
      }[params[:search_by].to_sym]

      @meta_datums = @meta_datums.send(filter_method, search_term)
    end

    if (type = params[:type]).present?
      @meta_datums = @meta_datums.where(type: type)
    end
  end
end
