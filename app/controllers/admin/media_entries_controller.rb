class Admin::MediaEntriesController < AdminController
  def index
    @media_entries = MediaEntry.page(params[:page]).per(16)
    filter if params[:search_term].present?
  end

  def show
    @media_entry = MediaEntry.find(params[:id])
  end

  private

  def filter
    @media_entries = @media_entries.search_with(params[:search_term])
  end
end
