require 'spec_helper'

describe MediaEntriesController do
  let(:user) { FactoryGirl.create(:user) }
  let(:vocabulary) do
    FactoryGirl.create(:vocabulary,
                       id: Faker::Lorem.characters(10),
                       enabled_for_public_view: true,
                       enabled_for_public_use: true)
  end
  let(:meta_key_text_1) do
    FactoryGirl.create(:meta_key_text,
                       vocabulary: vocabulary,
                       id: "#{vocabulary.id}:#{Faker::Lorem.characters(10)}")
  end
  let(:media_entry_1) do
    FactoryGirl.create(:media_entry, responsible_user: user)
  end
  let(:media_entry_2) do
    FactoryGirl.create(:media_entry, responsible_user: user)
  end

  context 'batch meta data update' do
    it 'logs into edit_sessions for all updated entries' do
      entry_1_before_count = media_entry_1.edit_sessions.count
      entry_2_before_count = media_entry_2.edit_sessions.count

      update_data = \
        {
          batch_resource_meta_data: {
            id: [media_entry_1.id, media_entry_2.id]
          },
          media_entry: {
            meta_data: {
              meta_key_text_1.id => { values: [Faker::Lorem.word] }
            }
          }
        }

      put :batch_meta_data_update,
          params: update_data.merge(format: :json, return_to: '/my'),
          session: { user_id: user.id },
          xhr: true

      expect(response.status).to be == 200

      entry_1_after_count = media_entry_1.reload.edit_sessions.count
      entry_2_after_count = media_entry_2.reload.edit_sessions.count

      expect(entry_1_after_count - entry_1_before_count).to be == 1
      expect(entry_2_after_count - entry_2_before_count).to be == 1
    end
  end
end
