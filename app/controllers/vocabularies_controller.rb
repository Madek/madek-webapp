class VocabulariesController < ApplicationController

  def index
    resources = Vocabulary.all
    authorized_resources = VocabularyPolicy::Scope
      .new(current_user, resources).resolve

    respond_with_react(
      Presenters::Vocabularies::VocabulariesIndex
        .new(authorized_resources, user: current_user))
  end

  def show
    vocab = Vocabulary.find(params.require(:vocabulary_id))
    authorize(vocab)
    respond_with_react(
      Presenters::Vocabularies::VocabularyShow.new(vocab, user: current_user))
  end

  def keywords # show action, with keyword tab
    vocabulary = find_by_vocab_id_param

    get = Presenters::Vocabularies::VocabularyKeywords.new(
      vocabulary, user: current_user)

    respond_with_react(get)
  end

  private

  def find_by_vocab_id_param
    vocabulary = Vocabulary.find(params.require('vocab_id'))
    authorize(vocabulary)
    vocabulary
  end
end
