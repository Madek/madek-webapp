class VocabulariesController < ApplicationController

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

end
