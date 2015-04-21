class Admin::KeywordTermsController < AdminController
  def index
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @keyword_terms = @vocabulary.keyword_terms.page(params[:page]).per(16)

    if (search_term = params[:search_term]).present?
      @keyword_terms = @keyword_terms.filter_by(search_term)
    end
  end

  def edit
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @keyword_term = KeywordTerm.find(params[:id])
  end

  def update
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @keyword_term = KeywordTerm.find(params[:id])
    @keyword_term.update!(keyword_term_params)

    redirect_to admin_vocabulary_keyword_terms_path(@vocabulary), flash: {
      success: ['The keyword term has been updated.']
    }
  end

  def new
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @keyword_term = KeywordTerm.new
  end

  def create
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @keyword_term = KeywordTerm.create(keyword_term_params)

    redirect_to admin_vocabulary_keyword_terms_path(@vocabulary), flash: {
      success: ['A keyword term has been created.']
    }
  end

  def destroy
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @keyword_term = KeywordTerm.find(params[:id])

    @keyword_term.destroy!
    redirect_to admin_vocabulary_keyword_terms_path(@vocabulary), flash: {
      success: ['The keyword term has been deleted.']
    }
  end

  private

  def keyword_term_params
    params.require(:keyword_term).permit(:term, :meta_key_id)
  end
end
