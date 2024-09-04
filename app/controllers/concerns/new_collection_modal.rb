module NewCollectionModal

  def new_collection
    auth_authorize :dashboard, :logged_in?

    error = flash[:error]

    @get = Presenters::Collections::CollectionNew.new(
      error: error,
      parent_collection: parent_collection
    )

    flash.clear
    respond_with @get, template: 'my/new_collection', layout: 'application'
  end

  private

  def parent_collection
    collection = Collection.find(params[:parent_id])
    auth_authorize collection, :add_remove_collection?
    collection
  rescue ActiveRecord::RecordNotFound # rubocop:disable Lint/HandleExceptions
    # do nothing
  end
end
