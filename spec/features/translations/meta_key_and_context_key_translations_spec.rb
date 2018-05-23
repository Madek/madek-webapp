require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Translations' do

  describe 'MetaKeys' do

    example 'labels w/fallbacks' do
      default_lang = 'de'
      available_langs = ['de', 'en']
      given_meta_keys = {
        uno: {
          de: 'Eins',
          en: 'One'
        },
        dos: {
          de: 'Zwei',
          en: nil
        },
        tres: {
          de: nil,
          en: 'Three'
        },
        quatro: {
          de: nil,
          en: nil
        }
      }

      expect(AppSetting.default_locale).to eq default_lang
      expect(AppSetting.available_locales.sort).to eq available_langs.sort

      vocab = create(:vocabulary, id: 'test_translation')
      create_keys(vocab, given_meta_keys)

      visit vocabulary_path(vocab, lang: 'de')
      expect(get_displayed_keys).to eq(
        'test_translation:uno': 'Eins',
        'test_translation:dos': 'Zwei',
        'test_translation:tres': 'Tres',
        'test_translation:quatro': 'Quatro')

      visit vocabulary_path(vocab, lang: 'en')
      expect(get_displayed_keys).to eq(
        'test_translation:uno': 'One',
        'test_translation:dos': 'Zwei',
        'test_translation:tres': 'Three',
        'test_translation:quatro': 'Quatro')
    end

  end
end

private

def create_keys(vocab, given_meta_keys)
  given_meta_keys.map do |id, labels|
    mk = create(
      :meta_key, vocabulary: vocab, id: "#{vocab.id}:#{id}", labels: labels)
    [id, mk]
  end.to_h
end

def get_displayed_keys
  within('[data-react-class="UI.Views.Vocabularies.VocabularyShow"]') do
    all('.row .prl.mbl').map do |div|
      label = div.find('h4').text
      id =  div.find('tr:first-child td.ui-summary-content').text
      [id.to_sym, label]
    end.to_h
  end
end
