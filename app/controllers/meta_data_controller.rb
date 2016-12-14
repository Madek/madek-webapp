class MetaDataController < ApplicationController
  include Concerns::MetaData
  include UuidHelper

  def show
    meta_datum = MetaDatum.find(params[:id])
    auth_authorize meta_datum
    @get = Presenters::MetaData::MetaDatumShow.new(meta_datum, current_user)
    respond_with @get
  end

  def new
    auth_authorize :meta_datum
  end

  def create
    meta_datum_klass = constantize_type_param(type_param)
    meta_datum = meta_datum_klass.create_with_user!(current_user, create_params)
    auth_authorize meta_datum
    @get = Presenters::MetaData::MetaDatumShow.new(meta_datum, current_user)
    render :show, status: :created
  end

  def edit
    meta_datum = MetaDatum.find(id_param)
    auth_authorize meta_datum
    @get = Presenters::MetaData::MetaDatumShow.new(meta_datum, current_user)
  end

  def update
    meta_datum = MetaDatum.find(id_param)
    auth_authorize meta_datum

    meta_datum.set_value!(value_param_for_update(meta_datum.type), current_user)

    if request.content_type == 'application/json'
      head 204
    else
      redirect_to meta_datum_path, status: 303, notice: 'Meta datum saved'
    end
  end

  def destroy
    meta_datum = MetaDatum.find(id_param)
    auth_authorize meta_datum
    meta_datum.destroy!

    subject_id = meta_datum.media_entry_id or \
    meta_datum.collection_id or meta_datum.filter_set_id

    redirect_to url_for(UuidHelper.find_resource_by_uuid(subject_id)),
                status: 303, notice: 'Meta datum destroyed successfully'
  end

  private

  def id_param
    params.require(:id)
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

  def create_params
    { media_entry_id: media_entry_id_param,
      collection_id: collection_id_param,
      filter_set_id: filter_set_id_param,
      meta_key_id: meta_key_id_param,
      type: type_param,
      value: raise_if_all_blanks_or_return_unchanged(value_param),
      created_by: current_user }
  end
end
