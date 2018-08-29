class MetaMetaDataController < ApplicationController

  def index
    clazz = \
      case params[:type]
      when 'MediaEntry' then MediaEntry
      when 'Collection' then Collection
      else
        throw 'not implemented'
      end
    respond_with(
      Presenters::MetaData::MetaMetaDataEdit.new(
        current_user,
        clazz
      )
    )
  end
end
