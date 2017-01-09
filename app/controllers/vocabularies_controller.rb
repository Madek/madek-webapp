class VocabulariesController < ApplicationController

  ALLOWED_FILTER_PARAMS = MediaEntriesController::ALLOWED_FILTER_PARAMS

  def index
    resources = Vocabulary.all
    authorized_resources = VocabularyPolicy::Scope
      .new(current_user, resources).resolve

    respond_with(@get = Presenters::Vocabularies::VocabulariesIndex
      .new(authorized_resources, user: current_user))
  end

  def show
    vocab = Vocabulary.find(params.require(:vocabulary_id))
    authorize(vocab)
    respond_with(@get = \
      Presenters::Vocabularies::VocabularyShow.new(vocab, user: current_user))
  end

  def keywords # show action, with keyword tab
    vocabulary = find_by_vocab_id_param

    @get = Presenters::Vocabularies::VocabularyKeywords.new(
      vocabulary, user: current_user)

    respond_with(@get)
  end

  def contents
    vocabulary = find_by_vocab_id_param

    resources_type = params.permit(:type).fetch(:type, nil)

    @get = Presenters::Vocabularies::VocabularyContents.new(
      vocabulary, current_user, resource_list_params, resources_type
    )

    respond_with(@get)
  end

  private

  def find_by_vocab_id_param
    vocabulary = Vocabulary.find(params.require('vocab_id'))
    authorize(vocabulary)
    vocabulary
  end
end
