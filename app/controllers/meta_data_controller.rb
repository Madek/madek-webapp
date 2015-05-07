class MetaDataController < ApplicationController

  def show
    meta_datum = MetaDatum.find(params[:id])
    @get = Presenters::MetaData::MetaDatumCommon.new(meta_datum)
  end

  def new
  end

  def create
    begin
      meta_datum_klass = type_param.constantize
      meta_datum = meta_datum_klass.create!(create_params)
      @get = Presenters::MetaData::MetaDatumCommon.new(meta_datum)
      render :show, status: :created
    rescue => e
      render text: e.message, status: :bad_request
    end
  end

  def edit
    meta_datum = MetaDatum.find(id_param)
    @get = Presenters::MetaData::MetaDatumCommon.new(meta_datum)
  end

  def update
    meta_datum = MetaDatum.find(id_param)

    begin
      meta_datum.update!(update_params)
      @get = Presenters::MetaData::MetaDatumCommon.new(meta_datum)
      render :show, status: :ok
    rescue => e
      render text: e.message, status: :bad_request
    end
  end

  def destroy
    meta_datum = MetaDatum.find(id_param)

    begin
      meta_datum.destroy!
      # TODO: enable simple text and remove template rendering
      # render text: 'Meta datum destroyed successfully', status: :ok
      render template: 'meta_data/destroy',
             status: :ok,
             locals: { text: 'Meta datum destroyed successfully',
                       media_entry_id: meta_datum.media_entry_id,
                       collection_id: meta_datum.collection_id,
                       filter_set_id: meta_datum.filter_set_id }
    rescue => e
      render text: e.message, status: :bad_request
    end
  end

  private

  def id_param
    params.require(:id)
  end

  def meta_key_id_param
    params.require(:_key)
  end

  def type_param
    params.require(:_value).require(:type)
  end

  def value_param
    params.require(:_value).fetch(:content)
  end

  def media_entry_id_param
    params[:media_entry_id]
  end

  def collection_id_param
    params[:collection_id]
  end

  def filter_set_id_param
    params[:filter_set_id]
  end

  def update_params
    { value: value_param }
  end

  def create_params
    { media_entry_id: media_entry_id_param,
      collection_id: collection_id_param,
      filter_set_id: filter_set_id_param,
      meta_key_id: meta_key_id_param,
      type: type_param,
      value: raise_if_all_blanks_or_return_unchanged(value_param) }
  end

  def raise_if_all_blanks_or_return_unchanged(array)
    array
      .tap do |vals|
        raise 'All values are blank!' if vals.all?(&:blank?)
      end
  end
end
