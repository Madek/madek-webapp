class VocabulariesController < ApplicationController
  include Concerns::KeywordTermRoutingHelper

  ALLOWED_FILTER_PARAMS = MediaEntriesController::ALLOWED_FILTER_PARAMS

  def index
    authorized_resources = auth_policy_scope(current_user, Vocabulary.all)

    respond_with(@get = Presenters::Vocabularies::VocabulariesIndex
      .new(authorized_resources, user: current_user))
  end

  def show
    vocab = Vocabulary.find(params.require(:vocabulary_id))
    auth_authorize(vocab)
    respond_with(@get = \
      Presenters::Vocabularies::VocabularyShow.new(vocab, user: current_user))
  end

  def keywords # show action, with keyword tab
    vocabulary = find_by_vocab_id_param

    @get = Presenters::Vocabularies::VocabularyKeywords.new(
      vocabulary, user: current_user)

    respond_with(@get)
  end

  def keyword_term
    # NOTE: only need to authorize the vocab (happens in the finder):
    vocab_id = meta_key_id_param.try(:split, ':').try(:first)
    vocabulary = find_by_vocab_id_param(vocab_id)
    keyword = Keyword.find_by!(
      term: keyword_term_param(action: 'term'), meta_key_id: meta_key_id_param)

    contents_path = filtered_index_path(
      meta_data: [{
        key: keyword.meta_key_id, value: keyword.id, type: 'MetaDatum::Keywords'
      }])

    respond_with(@get = Presenters::Vocabularies::VocabularyTerm.new(
      vocabulary, keyword, contents_path))
  end

  def contents
    vocabulary = find_by_vocab_id_param
    resources_type = params.permit(:type).fetch(:type, nil)

    @get = Presenters::Vocabularies::VocabularyContents.new(
      vocabulary, current_user, resource_list_params, resources_type
    )

    respond_with(@get)
  end

  def permissions
    vocabulary = find_by_vocab_id_param
    @get = Presenters::Vocabularies::VocabularyPermissions.new(
      vocabulary, current_user)

    respond_with(@get)
  end

  private

  def find_by_vocab_id_param(id = params.require('vocab_id'))
    vocabulary = Vocabulary.find(id)
    auth_authorize(vocabulary)
    vocabulary
  end
end
