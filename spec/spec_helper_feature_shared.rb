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

def find_input_with_name name
  find("textarea,input[name='#{name}']")
end

def sign_in_as login, password= 'password'
  visit "/"
  find("input[name='login']").set(login)
  find("input[name='password']").set(password)
  find("button[type='submit']").click
  User.find_by_login login
end

def submit_form
  find("form *[type='submit']").click
end
