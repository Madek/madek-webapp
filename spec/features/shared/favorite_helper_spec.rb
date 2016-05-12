require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

module FavoriteHelper

  def favorite_check_logged_in(user, resource)
    expect(resource.favored?(user)).to eq false
    favorite_button = find('.ui-body-title-actions').find('.icon-nofavorite')
      .find(:xpath, './/..')
    favorite_button.click
    expect(resource.favored?(user)).to eq true
    favorite_button = find('.ui-body-title-actions').find('.icon-favorite')
      .find(:xpath, './/..')
    favorite_button.click
    expect(resource.favored?(user)).to eq false
  end

  def favorite_check_logged_out
    expect(page).not_to have_selector('.icon-nofavorite')
    expect(page).not_to have_selector('.icon-favorite')
  end

end
