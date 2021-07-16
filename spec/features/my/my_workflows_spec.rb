require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'My: Workflows' do
  let(:user) { create :user }
  let(:beta_tester_group) { Group.find('e12e1bc0-b29f-5e93-85d6-ff0aae9a9db0') }

  describe 'Action: index' do
    context 'when user is a member of the beta-tester group' do
      background { beta_tester_group.users << user }

      scenario 'the view is rendered' do
        visit my_workflows_path

        sign_in_as user

        expect(page).to have_content(I18n.t(:workflows_index_header))
        expect(page).to have_link(I18n.t(:workflows_index_actions_new))
      end

      context 'when user is direct co-owner of the workflow' do
        given(:workflow) { create_workflow_for(create(:user)) }
        background do
          workflow.owners << user
        end

        scenario 'user can see the workflow on his list' do
          sign_in_as user

          visit my_workflows_path

          expect_workflow('My Test Workflow')
        end
      end

      context 'when user is an owner of the workflow through the delegation' do
        given(:workflow) { create_workflow_for(create(:user)) }
        given(:delegation) { create(:delegation) }

        context 'when user belongs to the delegation directly' do
          background do
            delegation.users << user
            workflow.delegations << delegation
          end

          scenario 'user can see the workflow on his list' do
            sign_in_as user

            visit my_workflows_path

            expect_workflow('My Test Workflow')
          end
        end

        context 'when user belongs to the delegation through a group' do
          given(:group) { create(:group) }
          background do
            group.users << user
            delegation.groups << group
            workflow.delegations << delegation
          end

          scenario 'user can see the workflow on his list' do
            sign_in_as user

            visit my_workflows_path

            expect_workflow('My Test Workflow')
          end
        end
      end

      context 'when user in not a member of the workflow' do
        background { create_workflow_for(create(:user)) }

        scenario 'user cannot see the workflow on his list' do
          sign_in_as user

          visit my_workflows_path

          expect_no_workflow('My Test Workflow')
        end
      end
    end

    context 'when user is not a member of the beta-tester group' do
      scenario 'the permissions error is displayed' do
        visit my_workflows_path

        sign_in_as user

        expect(page).to have_content(I18n.t(:error_403_title))
      end
    end
  end

  describe 'Showing link to Workflows' do
    context 'when user is a member of the beta-tester group' do
      scenario 'the link is visible' do
        beta_tester_group.users << user

        visit my_dashboard_path

        sign_in_as user

        expect(page).to have_link('Workflows')
      end
    end

    context 'when user is not a member of the beta-tester group' do
      scenario 'the link is not visible' do
        visit my_dashboard_path

        sign_in_as user

        expect(page).to have_no_link('Workflows')
      end
    end
  end

  describe 'Adding media entry to a workflow' do
    given!(:workflow) { create_workflow_for(user, logout_after: false) }

    scenario 'Media entry is listed only in incomplete list' do
      visit edit_my_workflow_path(workflow)
      click_link I18n.t(:workflow_associated_collections_upload)

      expect(page).to have_content(I18n.t(:workflow_uploader_notice_pre) + ' → ' + workflow.name)

      upload_file
      click_link I18n.t(:sitemap_my_archive)

      expect(page).to have_css('#unpublished_entries', text: 'Grumpy Cat')
      expect(page).to have_no_css('#content_media_entries', text: 'Grumpy Cat')
      expect(page).to have_css('#content_media_entries', text: I18n.t(:dashboard_none_exist))
      expect(page).to have_no_css('#latest_imports', text: 'Grumpy Cat')
      expect(page).to have_css('#latest_imports', text: I18n.t(:dashboard_none_exist))
    end
  end
end

def create_workflow_for(user, logout_after: true)
  name = 'My Test Workflow'
  beta_tester_group.users << user
  sign_in_as user
  within('.ui-side-navigation') { click_link 'Workflows' }
  click_link I18n.t(:workflows_index_actions_new)
  fill_in 'Name', with: name
  click_button I18n.t(:workflows_index_action_save)
  logout if logout_after
  Workflow.find_by(name: name)
end

def upload_file
  select_file_and_submit(
    'images',
    'grumpy_cat_new.jpg',
    input_name: 'media_entry[media_file][]',
    make_visible: true
  )
end

def expect_workflow(name)
  expect(page).to have_selector('.app-body-content .ui-resources-header .ui-resources-title',
                                text: name)
end

def expect_no_workflow(name)
  expect(page).to have_no_selector('.app-body-content .ui-resources-header .ui-resources-title',
                                   text: name)
end
