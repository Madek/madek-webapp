require "spec_helper_feature"
require "spec_helper_feature_shared"


feature "Admin - User Switch" do

  scenario "We sing-in as adam and become karen through 'switch-to'", 
    browser: :headless do

    @admin = sign_in_as 'adam'

    click_on_text "Adam Admin"
    click_on_text "Admin-Interface"
    click_on_text "Users & Groups"

    # show list of users  
    find("ul.menu-users-and-groups a.users").click

    # switch to karen 
    find("tr[data-login='karen'] a",text: "Switch to").click

    # now, we are signed in as karen
    find(".ui-header-user", text: "Karen")

  end

end

