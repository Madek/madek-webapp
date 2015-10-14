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

def click_on_text(text)
  wait_until { all('a, button', text: text, visible: true).size > 0 }
  find('a, button', text: text).click
end

def click_on_tab(text)
  find('.app-body .ui-tabs').find('a', text: text).click
end

def find_input_with_name(name)
  find("textarea,input[name='#{name}']")
end

# firefox only! - needs browser driver to support it
def move_mouse_over(element)
  page.driver.browser.action.move_to(element.native).perform
  # it's gonna be easier in capybara < 2.1
  # element.hover
end

def sign_in_as(login, password = 'password')
  visit '/admin' # save time by not redirecting to /my
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

def reload_without_js
  u = URI.parse(current_path)
  u.query = URI.encode_www_form \
    URI.decode_www_form(u.query || '').concat([['nojs', '1']])
  visit(u.to_s)
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
