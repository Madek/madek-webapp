class Admin::VocabulariesController < AdminController
  def index
    @vocabularies = Vocabulary.page(params[:page]).per(16).with_meta_keys_count

    if (search_term = params[:search_term]).present?
      @vocabularies = @vocabularies.filter_by(search_term)
    end
  end

  def show
    @vocabulary = Vocabulary.find(params[:id])
    @meta_keys =
      @vocabulary.meta_keys.with_keywords_count.page(params[:page]).per(16)
  end

  def edit
    @vocabulary = Vocabulary.find(params[:id])
  end

  define_update_action_for(Vocabulary)

  def new
    @vocabulary = Vocabulary.new
  end

  def create
    @vocabulary = Vocabulary.new(new_vocabulary_params)
    @vocabulary.save!

    respond_with @vocabulary, location: (lambda do
      admin_vocabularies_path
    end)
  end

  def destroy
    @vocabulary = Vocabulary.find(params[:id])
    @vocabulary.destroy!

    respond_with @vocabulary, location: (lambda do
      admin_vocabularies_path
    end)
  end

  private

  def new_vocabulary_params
    params.require(:vocabulary).permit!
  end

  def update_vocabulary_params
    params.require(:vocabulary).permit(:label, :description)
  end
end
