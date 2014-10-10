require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Dashboard" do

  background do
    @current_user = sign_in_as "normin"
    visit "/"
  end

  scenario "My resources" do

    within "#latest_user_resources_block" do
      check_presence_and_correctness_of_link "/my/media_resources"
    end

  end

  scenario "Showing last imports" do

    expect(find "#latest_user_imports_block").to be

  end

  scenario "Favorites" do

    within "#user_favorite_resources_block" do
      check_presence_and_correctness_of_link "/my/favorites"
    end

  end

  scenario "My keywords" do

    within "#user_keywords_block" do
      check_presence_and_correctness_of_link "/my/keywords"
    end

  end

  scenario "My entrusted resources" do

    within "#user_entrusted_resources_block" do
      check_presence_and_correctness_of_link "/my/entrusted_media_resources"
    end

  end

  scenario "My groups" do

    within "#my_groups_block" do
      check_presence_and_correctness_of_link "/my/groups"
    end

  end
  def check_presence_and_correctness_of_link href
    find("a[href*='#{href}']", match: :first).click
    assert_exact_url_path href
  end

end
