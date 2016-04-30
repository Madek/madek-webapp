require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

module UIHelpers

  def autocomplete_and_choose_first(node, text)
    unless Capybara.javascript_driver == :selenium
      throw 'Autocomplete is only supported in Selenium!'
    end
    ac = node.find('.ui-autocomplete-holder')
    input = ac.find('input')
    input.click
    input.native.send_keys(text)
    menu = ac.find('.ui-autocomplete.ui-menu')
    menu.first('.ui-menu-item').click
  end

end
