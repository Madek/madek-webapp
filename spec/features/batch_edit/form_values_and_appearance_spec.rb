require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/factory_helper_spec'
include FactoryHelper

feature 'Resource: MediaEntries' do

  describe 'Batch Meta Data Edit' do

    it 'Show Edit', browser: :firefox do

      prepare_data

      set_subtitle(@media_entry_1, 'SubtitleX')
      set_subtitle(@media_entry_2, 'SubtitleX')
      set_keywords(@media_entry_1, ['Keyword1', 'Keyword2'])
      set_keywords(@media_entry_2, ['Keyword1', 'Keyword2'])

      login

      open_edit(@media_entry_1, @media_entry_2)

      check_section('Madek Core', 'Title', true)
      check_section('Madek Core', 'Subtitle', false, 'SubtitleX')
      check_section('Madek Core', 'Schlagworte', false, 'Keyword1', 'Keyword2')
    end

    it 'Compare keywords', browser: :firefox do

      prepare_data

      set_keywords(@media_entry_1, ['Keyword1', 'Keyword2'])
      set_keywords(@media_entry_2, ['Keyword2', 'Keyword1'])

      login

      open_edit(@media_entry_1, @media_entry_2)

      check_section('Madek Core', 'Title', true)
      check_section('Madek Core', 'Schlagworte', false, 'Keyword1', 'Keyword2')
    end

  end

  def check_section(vocabulary, datum, expected_highlight, *expected_values)
    xpath_voc = './/div[contains(@class, "mbl")]'
    xpath_voc += '[.//h3[.//.[contains(.,"' + vocabulary + '")]]]'
    voc_div = find('.form-body').find(:xpath, xpath_voc)

    xpath_datum = './/fieldset[.//label[.//.[contains(.,"' + datum + '")]]]'
    dat_div = voc_div.find(:xpath, xpath_datum)

    xpath_form_item = './/div[@class="form-item"]'
    form_item = dat_div.find(:xpath, xpath_form_item)

    classes = dat_div[:class].split
    highlighted = classes.include?('highlight')

    expect(highlighted).to be(expected_highlight)

    check_form_values(form_item, expected_values)
  end

  def check_form_values(form_item, expected_values)
    multi_selects = form_item.all('.multi-select')
    if !multi_selects.empty?
      expect(multi_selects.length).to be(1)
      tags = multi_selects[0].all('.multi-select-tag')

      expect(tags.length).to be(expected_values.length)

      expected_values.each do |expected_value|
        xpath = './/.[@class="multi-select-tag"]'
        xpath += '[.//.[contains(.,"' + expected_value + '")]]'
        form_item.find(:xpath, xpath)
      end
    else
      input = form_item.find('input')

      if expected_values.empty?
        expect(input[:value]).to eq('')
      elsif expected_values.length == 1
        expect(input[:value]).to eq(expected_values[0])
      else
        expect(true).to eq(false)
      end
    end
  end

  def open_edit(*media_entries)
    parameters = { id: media_entries.map(&:id), return_to: '/my' }
    url = batch_edit_meta_data_media_entries_path + '?' + parameters.to_query
    visit url
  end

  def prepare_data
    prepare_user
    prepare_media_entries
    prepare_reference
  end

  def prepare_reference
    @ref_media_entry = prepare_media_entry('Reference')
    @ref_presenter = Presenters::MetaData::MetaDataEdit.new(
      @ref_media_entry, @user)
  end

  def prepare_media_entries
    @media_entry_1 = prepare_media_entry('MediaEntry1')
    @media_entry_2 = prepare_media_entry('MediaEntry2')
    @media_entry_3 = prepare_media_entry('MediaEntry3')
    @media_entry_4 = prepare_media_entry('MediaEntry4')
  end

end
