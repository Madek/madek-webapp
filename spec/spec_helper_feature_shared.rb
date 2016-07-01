# A few global functions shared between all rspec feature tests.
#
# * Keep this file lexically sorted.
#
# * Keep this file small and simple.
#
# * Only simple functions shall be included.
#
# * Only general functions shall be included.
#
# Favor clearness, and simplicity instead of dryness!
#

def click_on_tab(text)
  find('.app-body .ui-tabs').find('a', text: text).click
end

def find_input_with_name(name)
  find("textarea,input[name='#{name}']")
end

def current_path_with_query(full_url = current_url)
  url = URI.parse(full_url)
  url.path + (url.query.present? ? ('?' + url.query) : '')
end

# firefox only! - needs browser driver to support it
def move_mouse_over(element)
  page.driver.browser.action.move_to(element.native).perform
  # it's gonna be easier in capybara < 2.1
  # element.hover
end

def autocomplete_and_choose_first(node, text)
  unless Capybara.javascript_driver == :selenium
    throw 'Autocomplete is only supported in Selenium!'
  end
  # NOTE: mouse interaction does not work/is brittle and is manually tested!

  ac = node.find('.ui-autocomplete-holder')
  input = ac.find('input')
  input.hover
  input.click
  puts 'send_keys'
  input.native.send_keys(text)
  # wait until results are loaded and menu is open:
  wait_until { ac.find('.ui-autocomplete.ui-menu.tt-open') }
  # select first entry with keyboard navigation
  input.native.send_keys(:arrow_down)
  input.native.send_keys(:enter)
end

def dropdown_menu_and_get(toggle_text, menu_item_text)
  within('.ui-dropdown') do
    opened_menu = all('.ui-drop-menu', visible: true)[0]
    unless opened_menu
      find('.button', text: toggle_text).click # opens menu
    end
    opened_menu = find('.ui-drop-menu', visible: true)
    opened_menu.find('a', text: menu_item_text)
  end
end

def sign_in_as(login, password = 'password')
  visit '/my'
  # if ldap login is ON, first switch to correct form tab
  if db_user_tab = first('a#tab-internal_login')
    db_user_tab.click
  end
  fill_in 'login', with: login
  fill_in 'password', with: password
  find("[type='submit']").click
  User.find_by(login: login)
end

def submit_form
  # also works `within('form')`
  submit = first("form *[type='submit'], *[type='submit']")
  expect(submit).to be
  submit.click
end

def js_integration_test(name, data)
  visit '/styleguide/Scratchpad?'
  script = "runTest('#{name}', #{data.to_json})"
  puts "\nExecuting JavaScript: \n#{script}\n"
  evaluate_script(script)
  begin # this is added async, so capybara waits until the test is finished:
    result_node = page.find('#TestBedResult')
  rescue
    throw 'JavaScript timed out!'
  end
  result = JSON.parse(result_node.text)
  fail('JavaScript Error: ' + result['error']) if result['error']
  result
end
