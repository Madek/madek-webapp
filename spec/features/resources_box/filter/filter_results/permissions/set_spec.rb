require_relative '../../../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'set show box' do
  given(:config) { create_data(create_config) }
  given(:parent) { resource_by_id(config, :parent) }

  scenario 'check visibility permissions' do
    user = resource_by_id(config, :user_1)

    login(user)

    visit_resource(
      parent,
      type: 'entries',
      list: { show_filter: 'true', order: 'title ASC' }
    )
    check_content_by_ids(
      config,
      'title ASC',
      [*1..5].map { |i| "media_entry_#{i}".to_sym }
    )
    open_dynamic_filter('Berechtigung', 'Sichtbarkeit')
    check_dynamic_filter('Berechtigung', 'Sichtbarkeit', 'Nur für mich', 1)
    check_dynamic_filter(
      'Berechtigung',
      'Sichtbarkeit',
      'Geteilt mit Personen und Arbeitsgruppen',
      2)
    check_dynamic_filter('Berechtigung', 'Sichtbarkeit', 'Öffentlich', 1)

    visit_resource(
      parent,
      type: 'entries',
      list: {
        show_filter: 'true',
        order: 'title ASC',
        filter: {
          permissions: [
            key: 'visibility',
            value: 'user_or_group'
          ]
        }.to_json
      }
    )
    check_content_by_ids(
      config,
      'title ASC',
      [:media_entry_1, :media_entry_3]
    )

    visit_resource(
      parent,
      type: 'entries',
      list: {
        show_filter: 'true',
        order: 'title ASC',
        filter: {
          permissions: [
            key: 'visibility',
            value: 'private'
          ]
        }.to_json
      }
    )
    check_content_by_ids(
      config,
      'title ASC',
      [:media_entry_4]
    )

    visit_resource(
      parent,
      type: 'entries',
      list: {
        show_filter: 'true',
        order: 'title ASC',
        filter: {
          permissions: [
            key: 'responsible_delegation',
            value: config.detect { |entry| entry[:id] == :delegation }.fetch(:resource).id
          ]
        }.to_json
      }
    )
    check_content_by_ids(
      config,
      'title ASC',
      [:media_entry_5]
    )

    visit_resource(
      parent,
      type: 'entries',
      list: {
        show_filter: 'true',
        order: 'title ASC',
        filter: {
          permissions: [
            key: 'entrusted_to_group',
            value: config.detect { |entry| entry[:id] == :group_1 }.fetch(:resource).id
          ]
        }.to_json
      }
    )
    check_content_by_ids(
      config,
      'title ASC',
      [:media_entry_1]
    )

    visit_resource(
      parent,
      type: 'entries',
      list: {
        show_filter: 'true',
        order: 'title ASC',
        filter: {
          permissions: [
            key: 'entrusted_to_user',
            value: config.detect { |entry| entry[:id] == :user_2 }.fetch(:resource).id
          ]
        }.to_json
      }
    )
    check_content_by_ids(
      config,
      'title ASC',
      [:media_entry_3]
    )

    visit_resource(
      parent,
      type: 'entries',
      list: {
        show_filter: 'true',
        order: 'title ASC',
        filter: {
          permissions: [
            key: 'entrusted_to_api_client',
            value: config.detect { |entry| entry[:id] == :api_1 }.fetch(:resource).id
          ]
        }.to_json
      }
    )
    check_content_by_ids(
      config,
      'title ASC',
      [:media_entry_2]
    )

    visit_resource(
      parent,
      type: 'entries',
      list: {
        show_filter: 'true',
        order: 'title ASC',
        filter: {
          permissions: [
            key: 'visibility',
            value: 'public'
          ]
        }.to_json
      }
    )
    check_content_by_ids(
      config,
      'title ASC',
      [:media_entry_5]
    )
  end

  context 'when user is not logged in' do
    scenario 'only Accessability filter is visible' do
      visit_resource(
        parent,
        type: 'entries',
        list: { show_filter: 'true', order: 'title ASC' }
      )

      section = open_section('Berechtigung')

      expect(find_sub_section(section, I18n.t(:dynamic_filters_visibility))).to be
      expect { find_sub_section(section, I18n.t(:permissions_responsible_user_title)) }
        .to raise_error(Capybara::ElementNotFound)
      expect { find_sub_section(section, I18n.t(:permissions_responsible_delegation_title)) }
        .to raise_error(Capybara::ElementNotFound)
      expect { find_sub_section(section, I18n.t(:permission_entrusted_to_user)) }
        .to raise_error(Capybara::ElementNotFound)
      expect { find_sub_section(section, I18n.t(:permission_entrusted_to_group)) }
        .to raise_error(Capybara::ElementNotFound)
      expect { find_sub_section(section, I18n.t(:permission_entrusted_to_api_client)) }
        .to raise_error(Capybara::ElementNotFound)
    end
  end

  private

  # rubocop:disable Metrics/MethodLength
  def create_config
    [
      {
        type: User,
        id: :user_1
      },
      {
        type: User,
        id: :user_2
      },
      {
        type: Group,
        id: :group_1
      },
      {
        type: Delegation,
        id: :delegation
      },
      {
        type: ApiClient,
        id: :api_1
      },
      {
        type: MediaEntry,
        id: :media_entry_1,
        title: 'MediaEntry1',
        user: :user_1,
        created_at: 1,
        last_change: 1,
        visibility: :private,
        groups: [:group_1]
      },
      {
        type: MediaEntry,
        id: :media_entry_2,
        title: 'MediaEntry2',
        user: :user_1,
        created_at: 2,
        last_change: 2,
        visibility: :private,
        apis: [:api_1]
      },
      {
        type: MediaEntry,
        id: :media_entry_3,
        title: 'MediaEntry3',
        user: :user_1,
        created_at: 3,
        last_change: 3,
        visibility: :private,
        users: [:user_2]
      },
      {
        type: MediaEntry,
        id: :media_entry_4,
        title: 'MediaEntry4',
        user: :user_1,
        created_at: 4,
        last_change: 4,
        visibility: :private
      },
      {
        type: MediaEntry,
        id: :media_entry_5,
        title: 'MediaEntry5',
        user: :user_1,
        created_at: 5,
        last_change: 5,
        responsible_delegation: :delegation
      },
      {
        type: Collection,
        id: :parent,
        title: 'Parent',
        user: :user_1,
        created_at: 0,
        last_change: 0,
        children: [*1..5].map { |i| "media_entry_#{i}".to_sym }
      }
    ]
  end
  # rubocop:enable Metrics/MethodLength
end
