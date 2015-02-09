class Admin::VocablesController < AdminController
  def index
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @vocables = @vocabulary.vocables.page(params[:page]).per(16)

    if (search_term = params[:search_term]).present?
      @vocables = @vocables.filter_by(search_term)
    end
  end

  def edit
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @vocable = Vocable.find(params[:id])
  end

  def update
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @vocable = Vocable.find(params[:id])
    @vocable.update!(vocable_params)

    redirect_to admin_vocabulary_vocables_path(@vocabulary), flash: {
      success: 'The vocable has been updated.'
    }
  end

  def new
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @vocable = Vocable.new
  end

  def create
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @vocable = Vocable.create(vocable_params)

    redirect_to admin_vocabulary_vocables_path(@vocabulary), flash: {
      success: 'A vocable has been created.'
    }
  rescue => e
    redirect_to admin_vocabulary_vocables_path(@vocabulary), flash: {
      error: e.to_s
    }
  end

  def destroy
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @vocable = Vocable.find(params[:id])

    @vocable.destroy!
    redirect_to admin_vocabulary_vocables_path(@vocabulary), flash: {
      success: 'The vocable has been deleted.'
    }
  rescue => e
    redirect_to admin_vocabulary_vocables_path(@vocabulary), flash: {
      error: e.to_s
    }
  end

  private

  def vocable_params
    params.require(:vocable).permit(:term, :meta_key_id)
  end
end
