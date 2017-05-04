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
      meta_key = MetaKey.find('madek_core:keywords')
      random_keywords_to_check = meta_key.keywords.sample(8)

      random_keywords_to_check.each do |keyword|
        # NOTE: no link in UI yet, go there directly:
        visit(
          vocabulary_meta_key_term_path(
            term: keyword.term, meta_key_id: meta_key.id))

        expect(get_displayed_ui).to eq(
          title: {
            icon: 'icon-tag',
            title: "\"#{keyword.term}\""
          },
          page: {
            info_table: [
              ['Begriff', keyword.term],
              ['Metakey', "#{meta_key.label} (#{meta_key.id})"],
              ['Typ', 'Keyword'],
              ['Vokabular', meta_key.vocabulary.label]
            ]
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
