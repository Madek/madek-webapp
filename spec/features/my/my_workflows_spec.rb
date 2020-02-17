require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'My: Workflows' do
  let(:user) { create :user }
  let(:beta_tester_group) { Group.find('e12e1bc0-b29f-5e93-85d6-ff0aae9a9db0') }

  describe 'Action: index' do
    context 'when user is a member of the beta-tester group' do
      scenario 'the view is rendered' do
        beta_tester_group.users << user

        visit my_workflows_path

        sign_in_as user

        expect(page).to have_content(I18n.t(:workflows_index_header))
        expect(page).to have_link(I18n.t(:workflows_index_actions_new))
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
