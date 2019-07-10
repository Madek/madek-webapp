require 'spec_helper'

describe MetaDataController do
  it 'show' do
    # not logged in and no public view permission for the vocabulary
    media_entry = FactoryGirl.create(:media_entry)
    vocabulary = FactoryGirl.create(:vocabulary,
                                    enabled_for_public_view: false)
    meta_key = FactoryGirl.create(:meta_key_text)
    meta_key.vocabulary = vocabulary
    meta_datum = FactoryGirl.create(:meta_datum_text,
                                    media_entry: media_entry,
                                    meta_key: meta_key)

    expect { get :show, params: { id: meta_datum.id } }
      .to raise_error Errors::UnauthorizedError
  end

  it 'create' do
    # logged in but no edit data permission for media entry
    user = FactoryGirl.create(:user)
    media_entry = FactoryGirl.create(:media_entry,
                                     responsible_user: FactoryGirl.create(:user))
    vocabulary = FactoryGirl.create(:vocabulary)
    meta_key = FactoryGirl.create(:meta_key_text)
    meta_key.vocabulary = vocabulary

    expect do
      post :create,
           params: {
             media_entry_id: media_entry.id,
             meta_key: meta_key.id,
             type: 'MetaDatum::Text',
             values: ['text'] },
           session: { user_id: user.id }
    end.to raise_error Errors::ForbiddenError
  end
end
