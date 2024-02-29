require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/vocabulary_shared'
include VocabularyShared

feature 'Resource: Vocabulary' do
  let(:user) { User.find_by(login: 'normin') }

  context 'PermissionsShow' do

    example 'madek_core Vocabulary' do
      vocabulary = Vocabulary.find('madek_core')
      visit vocabulary_permissions_path(vocab_id: vocabulary)

      check_title(vocabulary.label)
      check_tabs(
        [
          { key: :vocabularies_tabs_vocabulary, active: false },
          { key: :vocabularies_tabs_keywords, active: false },
          { key: :vocabularies_tabs_contents, active: false },
          { key: :vocabularies_tabs_permissions, active: true }
        ]
      )

      within('.tab-content') do
        expect(page).to have_content I18n.t(:vocabulary_permissions_hint1)
        expect(page).to have_content I18n.t(:vocabulary_permissions_hint2)
        expect(displayed_permissions).to eq(
          'Öffentlichkeit' => [
            { 'Internet' => { 'Betrachten' => true, 'Anwenden' => true } }
          ]
        )
      end
    end

    example 'custom Vocabulary' do
      v = FactoryBot.create(
        :vocabulary, enabled_for_public_use: false, enabled_for_public_view: false)

      v.user_permissions << FactoryBot.create(
        :vocabulary_user_permission, user: user, view: true)
      3.times do
        v.user_permissions << FactoryBot.create(:vocabulary_user_permission)
      end
      7.times do
        v.group_permissions << FactoryBot.create(:vocabulary_group_permission)
        group = v.group_permissions.last.group
        if (FactoryHelper.rand_bool 1 / 2.0) && !group.users.exists?(user.id)
          group.users << user
        end
      end
      3.times do
        v.api_client_permissions <<
          FactoryBot.create(:vocabulary_api_client_permission)
      end

      visit vocabulary_permissions_path(vocab_id: v)

      # not visible for public!
      expect(page).to have_content I18n.t(:error_401_title)
      sign_in_as user

      check_title(v.label)
      check_tabs(
        [
          { key: :vocabularies_tabs_vocabulary, active: false },
          { key: :vocabularies_tabs_contents, active: false },
          { key: :vocabularies_tabs_permissions, active: true }
        ]
      )

      within('.tab-content') do
        expect(page).to have_content I18n.t(:vocabulary_permissions_hint1)
        expect(page).to have_content I18n.t(:vocabulary_permissions_hint2)
        expect(displayed_permissions).to eq(
          'Nutzer/innen' => v.user_permissions.map do |p|
            { p.user.to_s =>
              { 'Betrachten' => p.view, 'Anwenden' => p.use } }
          end,
          'Gruppen' => v.group_permissions.map do |p|
            member = true if p.group.users.exists?(user.id)
            { p.group.name =>
              { 'Betrachten' => p.view, 'Anwenden' => p.use }.merge(
                if member
                  { isLink: true }
                else
                  {}
                end
              )
            }
          end,
          'API-Applikationen' => v.api_client_permissions.map do |p|
            { p.api_client.login => { 'Betrachten' => p.view, 'Anwenden' => nil } }
          end,
          'Öffentlichkeit' => [{
            'Internet' => { 'Betrachten' => false, 'Anwenden' => false }
          }]
        )
      end

    end

  end

end

private

def displayed_permissions
  rows = all('form > div.ui-rights-management > div')
  titles = rows.first.all('td.ui-rights-check-title').map(&:text)

  rows.map do |rows|
    [
      rows.find('thead td.ui-rights-user-title').text,
      rows.all('tbody > tr').map do |row|
        {
          row.find('td.ui-rights-user').text =>
          row.all('td.ui-rights-check').map.with_index do |perm, i|
            state = if perm.all('.icon-checkmark').first.present?
              true
            elsif perm.all('.pseudo-icon-dash').first.present?
              false
            end
            [titles[i], state]
          end.to_h.merge(
            if row.find('td.ui-rights-user').all('a').empty?
              {}
            else
              { isLink: true }
            end
          )
        }
      end
    ]
  end.to_h
end
# rubocop:enable Metrics/MethodLength
