class MediaEntriesController < ApplicationController

  respond_to :html

  def index
    @media_entries = MediaEntry.all
  end

  def show
    @media_entry = MediaEntry.find params[:id]
  end

  def new
    @media_entry = MediaEntry.new
  end

  def create
    @media_entry = MediaEntry.create media_entry_params

    if @media_entry.persisted?
      flash[:notice] = _(:media_entry_create_success_message)
    else
      flash[:error] = _(:media_entry_create_error_message)
    end

    respond_with @media_entry
  end

  def update
    @media_entry = MediaEntry.find params[:id]
    updated_successfully = @media_entry.update(media_entry_params)

    if updated_successfully
      flash[:notice] = _(:media_entry_update_success_message)
    else
      flash[:error] = _(:media_entry_update_error_message)
    end

    respond_with @media_entry
  end

  def destroy
    @media_entry = MediaEntry.find params[:id]
    @media_entry.destroy

    if @media_entry.destroyed?
      flash[:notice] = _(:media_entry_destroy_success_message)
    else
      flash[:error] = _(:media_entry_destroy_error_message)
    end

    respond_with @media_entry, location: my_dashboard_path(current_user), action: :edit
  end

  private

  def media_entry_params
    params.permit(:responsible_user_id, :title)
  end

end
