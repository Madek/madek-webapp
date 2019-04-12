require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

require_relative '../shared/vocabulary_shared'
include VocabularyShared

feature 'Vocabulary Pages' do
  describe 'Keyword Term Show' do

    it 'is displayed correctly' do
      # test 16 keywords, 8 existing + 8 custom ones
      random_keywords_to_check = [
        MetaKey.find('madek_core:keywords').keywords.sample(8),
        8.times.map { create(:keyword, :license) }
      ].flatten.shuffle

      random_keywords_to_check.each do |keyword|
        kw = keyword
        meta_key = keyword.meta_key
        visit(vocabulary_keywords_path(keyword.meta_key.vocabulary.id))
        click_on keyword.term

        expect(page).to have_current_path \
          vocabulary_meta_key_term_show_path(keyword.id)

        expect(get_displayed_ui).to eq(
          title: {
            icon: 'icon-tag',
            title: "\"#{keyword.term}\""
          },
          page: {
            info_table: [
              ['Begriff', keyword.term],
              (['Beschreibung', keyword.description] if kw.description),
              (['URL', keyword.external_uris.join(' ')] if kw.external_uris.any?),
              ['Metakey', "#{meta_key.label} (#{meta_key.id})"],
              ['Typ', keyword.rdf_class],
              ['Vokabular', meta_key.vocabulary.label]
            ].compact
          }
        )
      end
    end

  end

  private

  def get_displayed_ui
    within('.app-body-ui-container') do
      {
        title: within('.ui-body-title h1.title-xl') do
          { icon: find('i')[:class], title: page.text }
        end,
        page: within('.ui-container.bright') do
          {
            info_table: within('table.borderless tbody') do
              all('tr').map do |tr|
                [
                  tr.find('.ui-summary-label').text,
                  tr.find('.ui-summary-content').text
                ]
              end
            end
          }
        end
      }
    end
  end

end
