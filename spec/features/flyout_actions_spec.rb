require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative 'shared/basic_data_helper_spec'
require_relative 'shared/meta_data_helper_spec'
include BasicDataHelper
include MetaDataHelper

feature 'Resource: Collection/MediaEntry' do
  describe 'Flyout Actions' do

    it 'Edit meta data from flyout for media entry.', browser: :firefox do
      scenario_edit_meta_data(MediaEntry)
    end

    it 'Edit meta data from flyout for collection.', browser: :firefox do
      scenario_edit_meta_data(Collection)
    end

    it 'Delete media entry from flyout.', browser: :firefox do
      scenario_delete(MediaEntry)
    end

    it 'Delete collection from flyout.', browser: :firefox do
      scenario_delete(Collection)
    end

  end

  def open_resource_and_hover(type)
    prepare_and_login
    @resource = self.send('create_' + type.name.underscore, 'Test')
    visit my_dashboard_path
    xpath = './/.[@class="ui-resource"]'
    xpath += '[.//.[@class="ui-thumbnail-meta-title"][contains(.,"Test")]]'
    resource_element = find(:xpath, xpath)
    resource_element.hover
  end

  def scenario_edit_meta_data(type)
    open_resource_and_hover(type)
    find('.icon-pen').hover
    find('.icon-pen').click
    expect(current_path).to eq self.send(
      'edit_meta_data_' + type.name.underscore + '_path', @resource)
  end

  def scenario_delete(type)
    open_resource_and_hover(type)
    find('.icon-trash').hover
    find('.icon-trash').click
    id = @resource.id
    underscore = type.name.underscore
    title = I18n.t((underscore + '_ask_delete_title').to_sym)
    expect(page).to have_content(title)
    find('.primary-button', text: I18n.t(:resource_ask_delete_ok)).click
    expect(current_path).to eq my_dashboard_path
    flash = I18n.t((underscore + '_delete_success').to_sym)
    expect(page).to have_content(flash)
    resources = type.where(id: id)
    expect(resources.length).to eq(0)
  end

  def prepare_and_login
    prepare_user
    login
  end

end
