require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Login" do

  scenario "Login with database authentication" do

    root_path
    sign_in_as "normin"
    expect { find("a#user-action-button", text: "Normin") }.not_to raise_error

  end

  scenario "Accepting usage terms after fresh login" do

    login = "normin"

    # the user has not yet accepted the usage terms
    User.find_by_login(login).update_attributes!(usage_terms_accepted_at: nil)

    sign_in_as login

    assert_modal_visible "Nutzungsbedingungen"
    submit_form
    expect(current_path).to eq "/my"

  end

  scenario "Rejecting usage terms after fresh login" do

    login = "normin"

    # the user has not yet accepted the usage terms
    User.find_by_login(login).update_attributes!(usage_terms_accepted_at: nil)

    sign_in_as login

    assert_modal_visible "Nutzungsbedingungen"
    find("a", text: "Ablehnen").click
    expect(current_path).to eq "/"

    assert_error_alert "Nutzungsbedingungen"

  end

end
