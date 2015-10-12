class Admin::KeywordsController < AdminController
  def index
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @keywords = @vocabulary.keywords.page(params[:page]).per(16)

    @keywords = @keywords.filter_by(params[:search_term],
                                    params[:meta_key_id])
  end

  def edit
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @keyword = Keyword.find(params[:id])
  end

  def update
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @keyword = Keyword.find(params[:id])
    @keyword.update!(keyword_params)

    respond_with @keyword, location: (lambda do
      admin_vocabulary_keywords_path(@vocabulary)
    end)
  end

  def new
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @keyword = Keyword.new
  end

  def create
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @keyword = Keyword.create(keyword_params)

    respond_with @keyword, location: (lambda do
      admin_vocabulary_keywords_path(@vocabulary)
    end)
  end

  def destroy
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    @keyword = Keyword.find(params[:id])

    @keyword.destroy!
    respond_with @keyword, location: (lambda do
      admin_vocabulary_keywords_path(@vocabulary)
    end)
  end

  private

  def keyword_params
    params.require(:keyword).permit(:term, :meta_key_id)
  end
end
