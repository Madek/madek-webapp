require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../../shared/basic_data_helper_spec'
include BasicDataHelper

feature 'Meta key grouping' do

  scenario 'Only group keys' do

    # configure bundling
    Settings.ui_bundle_context_keys = [
      { group: 'test_vocabulary:test_group_1',
        prefix: 'test_vocabulary:test_group_1_'
      },
      { group: 'test_vocabulary:test_group_2_value_1',
        prefix: 'test_vocabulary:test_group_2_'
      }
    ]

    data = prepare_data_and_login

    create_context_key(data, 'test_vocabulary:test_group_1', 1)
    create_context_key(data, 'test_vocabulary:test_group_1_value_1', 2)
    create_context_key(data, 'test_vocabulary:test_group_x', 3)
    create_context_key(data, 'test_vocabulary:test_group_1_value_2', 4)
    create_context_key(data, 'test_vocabulary:test_group_2_value_1', 5)
    create_context_key(data, 'test_vocabulary:test_group_2_value_2', 6)

    visit edit_path(data[:resource], data[:context])

    grouped_labels = [
      [
        'test_vocabulary:test_group_1',
        ['test_vocabulary:test_group_1_value_1']
      ],
      [
        'test_vocabulary:test_group_x',
        []
      ],
      [
        'test_vocabulary:test_group_1_value_2',
        []
      ],
      [
        'test_vocabulary:test_group_2_value_1',
        ['test_vocabulary:test_group_2_value_2']
      ]
    ]

    check_grouped_labels(grouped_labels)
  end

  private

  def check_no_grouping(outer_form_group)
    expect(outer_form_group).to have_no_selector('.ui-form-group')
    expect(outer_form_group).to have_no_selector(
      'button',
      text: I18n.t(:meta_data_edit_more_data))
  end

  def open_more_data(outer_form_group)
    outer_form_group.find(
      '.button',
      text: I18n.t(:meta_data_edit_more_data))
    .click
  end

  def check_grouping(outer_form_group, inner_labels)
    open_more_data(outer_form_group)

    inner_form_groups = outer_form_group.all('.ui-form-group')
    expect(inner_form_groups.length).to eq(inner_labels.length)

    inner_form_groups.zip(inner_labels).each do |pair|
      check_inner_label(pair.first, pair.last)
    end
  end

  def check_inner_label(inner_form_group, inner_label)
    inner_form_group.find('.form-label', text: inner_label)
  end

  def check_outer_label(outer_form_group, grouped_label)
    outer_label = grouped_label[0]
    inner_labels = grouped_label[1]

    outer_form_group.find('* > .form-label', text: outer_label)

    if inner_labels.empty?
      check_no_grouping(outer_form_group)
    else
      check_grouping(outer_form_group, inner_labels)
    end
  end

  def check_grouped_labels(grouped_labels)
    outer_form_groups = all('.form-body > .ui-form-group')
    expect(outer_form_groups.length).to eq(grouped_labels.length)

    outer_form_groups.zip(grouped_labels).each do |pair|
      check_outer_label(pair.first, pair.last)
    end
  end

  def edit_path(resource, context)
    self.send(
      "edit_meta_data_by_context_#{resource.class.name.underscore}_path",
      resource,
      context)
  end

  def login(user)
    sign_in_as user.login, user.password
  end

  def create_context_key(data, id, position)
    meta_key = FactoryGirl.create(:meta_key, id: id)
    FactoryGirl.create(
      :context_key,
      labels: { de: id },
      context: data[:context],
      meta_key: meta_key,
      position: position)
  end

  def prepare_data_and_login
    data = prepare_data
    login(data[:user])
    data
  end

  def prepare_data
    user = FactoryGirl.create(:user)
    context = FactoryGirl.create(:context)
    media_entry = FactoryGirl.create(:media_entry, responsible_user: user)

    app_setting = AppSetting.first
    app_setting[:contexts_for_entry_edit] << context.id
    app_setting.save

    {
      user: user,
      context: context,
      resource: media_entry
    }
  end
end
