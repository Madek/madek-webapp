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

def click_on_text text
  wait_until{ all("a, button", text: text, visible: true).size > 0}
  find("a, button", text: text).click
end

def click_on_button text
  find(".button[title=\"#{text}\"]").click
end

def find_input_with_name name
  find("textarea,input[name='#{name}']")
end

# firefox only! - needs browser driver to support it
def move_mouse_over element
  page.driver.browser.action.move_to(element.native).perform
  # it's gonna be easier in capybara < 2.1
  # element.hover
end

def sign_in_as login, password= 'password'
  visit "/"
  # if ldap login is ON, first switch to correct form tab
  if db_user_tab = first('a#database-user-login-tab')
    db_user_tab.click
  end
  find("input[name='login']").set(login)
  find("input[name='password']").set(password)
  find("button[type='submit']").click
  User.find_by_login login
end

def submit_form
  find("form *[type='submit']").click
end
