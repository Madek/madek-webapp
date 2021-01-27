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
end

def create_workflow_for(user)
  name = 'My Test Workflow'
  sign_in_as user
  beta_tester_group.users << user
  visit my_workflows_path
  click_link I18n.t(:workflows_index_actions_new)
  fill_in 'Name', with: name
  click_button I18n.t(:workflows_index_action_save)
  logout
  Workflow.find_by(name: name)
end

def expect_workflow(name)
  expect(page).to have_selector('.app-body-content .ui-resources-header .ui-resources-title',
                                text: name)
end

def expect_no_workflow(name)
  expect(page).to have_no_selector('.app-body-content .ui-resources-header .ui-resources-title',
                                   text: name)
end
