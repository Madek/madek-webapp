class MediaEntriesController < ApplicationController

  def index
    @media_entries = \
      filter_by_entrusted \
      filter_by_favorite \
      filter_by_imported \
      filter_by_responsible \
      MediaEntry.all
  end

  def show
    @media_entry = MediaEntry.find(params[:id])
  end

  private

  def filter_by_responsible(media_entries)
    filter_by_param_or_return_unchanged \
      media_entries, :in_responsibility_of,
      params[:responsible], 'true'
  end

  def filter_by_imported(media_entries)
    filter_by_param_or_return_unchanged \
      media_entries, :created_by,
      params[:imported], 'true'
  end

  def filter_by_favorite(media_entries)
    filter_by_param_or_return_unchanged \
      media_entries, :favored_by,
      params[:favorite], 'true'
  end

  def filter_by_entrusted(media_entries)
    filter_by_param_or_return_unchanged \
      media_entries, :entrusted_to_user,
      params[:entrusted], 'true'
  end

  def filter_by_param_or_return_unchanged(media_entries, scope, param, value)
    if param == value
      media_entries.send(scope, current_user)
    else
      media_entries
    end
  end
end
