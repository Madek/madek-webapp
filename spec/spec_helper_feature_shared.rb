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

# run a block containing an async navigation action. will wait until URL changed.
def async_nav(wait_seconds = 15, &block)
  previous_url = current_url
  yield(block)
  wait_until(wait_seconds) { previous_url != current_url }
end

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

def find_exact_text(locator, text:)
  page.find(locator, text: Regexp.new("^#{text}$"))
end

def click_select_all_on_first_page
  pager = find('.ui-resources-page').find('.ui-pager')
  if pager.all('.icon-checkbox-active').first
    pager.all('.icon-checkbox-active').first.click
  elsif pager.all('.icon-checkbox-mixed').first
    pager.all('.icon-checkbox-mixed').first.click
  else
    pager.all('.icon-checkbox').first.click
  end
end

def click_deselect_all_on_first_page
  find('.ui-resources-page').find('.ui-pager').find(
    '.icon-checkbox-active').click
end

# firefox only! - needs browser driver to support it
def move_mouse_over(element)
  page.driver.browser.action.move_to(element.native).perform
  # it's gonna be easier in capybara < 2.1
  # element.hover
end

def autocomplete_and_choose_first(node, text, press_escape: false)
  unless Capybara.javascript_driver == :selenium
    throw 'Autocomplete is only supported in Selenium!'
  end
  # NOTE: mouse interaction does not work/is brittle and is manually tested!
  ac = node.find('.ui-autocomplete-holder')
  input = node.find('.ui-autocomplete-holder input') # needs full selector!
  input.hover
  input.click
  puts 'send_keys'
  input.native.send_keys(text)
  # wait until menu is open and at least 1 result has loaded:
  wait_until { ac.all('.ui-autocomplete.ui-menu.tt-open .tt-selectable').any? }
  # select first entry with keyboard navigation
  input.native.send_keys(:arrow_down)
  input.native.send_keys(:enter)
  # Since for the keywords we prefill n entries in the dropdown as soon as
  # the focus is in the input field, the dropdown is not closed after selection
  # because of the focus is still in the input field. In this case we
  # close the dropdown pressing escape, otherwise it will cover other
  # elements which are covered by the dropdown.
  if press_escape
    input.native.send_keys(:escape)
  end
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

def sign_in_as(login, password = nil)
  # allow user instance
  if login.is_a?(User)
    user = login
    login = user.login
  else
    user = User.find_by!(login: login.downcase)
    login = login
  end

  # bail if already signed in
  return if page.document.all('.ui-header-user').try(:first)
    .try(:text).try(:starts_with?, user.person.first_name)

  # for factory-created users, get their password; otherwise use static fallback
  unless password.present?
    password = user.try(:password) || 'password'
  end

  # if there isn't already a login form, force it:
  visit '/my/used_keywords' unless page.has_selector?('#login_menu form')

  # if ldap login is ON, first switch to correct form tab
  if db_user_tab = all('a#tab-internal_login').first
    db_user_tab.click
  end
  fill_in 'login', with: login
  fill_in 'password', with: password
  find("[type='submit']").click
  User.find_by(login: login)
end

def logout
  find('.ui-header-user').find('.dropdown-toggle').click
  find('.ui-header-user').find('.dropdown-menu')
    .find('.ui-drop-item', text: I18n.t(:user_menu_logout_btn)).click
end

def submit_form
  # 1. Madek UI convention:
  #    use the "primary" button (async forms where implicit submit is off)
  # 2. HTML convention: use the submit button if there is one
  # 3/4. try the same, but assuming we are 'within' a form
  submit = first("\
    form .ui-actions .primary-button, \
    form *[type='submit'], \
    *.ui-actions .primary-button, \
    *[type='submit']")
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
