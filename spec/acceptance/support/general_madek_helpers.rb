def set_up_world
  # Set this to a non-JS driver because:
  # 1. The Selenium driver times out during this step
  # 2. This step may be called in backgrounds of tests that have
  #    :js => true, so this would break this step. Therefore
  #    we set our own driver here.
  old_driver = Capybara.current_driver
  Capybara.use_default_driver

  if MetaKey.count == 0 # TODO: Test for more stuff, just having more than 0
                        # keys doesn't guarantee the YAML file has already been
                        # loaded.
    user = create_user("Bruce Willis", "bruce_willis", "fluffyKittens")
    group = create_group("Admin")
    add_user_to_group(user, group)
    log_in_as("bruce_willis", "fluffyKittens")
    visit homepage
    click_on_arrow_next_to("Willis, Bruce")
    click_link("Admin")
    click_link("Import")
    attach_file("uploaded_data", Rails.root + "spec/data/minimal_meta.yml")
    click_button("Import »")
  end

  MetaKey.count.should == 89
  Capybara.current_driver = old_driver

  # This is actually normally called in the seeds, but
  # the RSpec developers don't believe in using seeds, so
  # they drop the database even if we seed it before running
  # the tests. Therefore we recreate our world in this step.
  Copyright.init
  Permission.init
  Meta::Department.fetch_from_ldap
  Meta::Date.parse_all
  
end


def make_hidden_items_visible
  page.execute_script '$(":hidden").show();'
end

def click_on_arrow_next_to(word)
  find(".head_menu", :text => "#{word}").find("img.arrow").click
end

def log_in_as(username, password)
#   puts "all users in the scenario are: #{User.all.inspect}"
#   puts "the login attempt is as: #{username} #{password}"
#   puts "SHA1 is: " + Digest::SHA1.hexdigest(password)
  visit "/logout"
  visit "/db/login"
  fill_in "login", :with => username
  fill_in "password", :with => password
  click_link_or_button "Log in"
  return User.where(:login => username,
                    :password => Digest::SHA1.hexdigest(password)).first
end

def create_user(person_name, username, password)
  user = User.where(:login => username).first
  if user.nil?
    firstname, lastname = person_name, person_name
    firstname, lastname = person_name.split(" ") if person_name.include?(" ")
    crypted_password = Digest::SHA1.hexdigest(password)
    person = Person.find_or_create_by_firstname_and_lastname(:firstname => firstname,
                                                            :lastname => lastname)
    user = person.build_user(:login => username,
                            :email => "#{username}@zhdk.ch",
                            :password => crypted_password)
    user.usage_terms_accepted_at = DateTime.now
    user.save
  end
  return user
end

def create_group(groupname)
  group = Group.where(:name => groupname).first
  if group.nil?
    group = Group.create(:name => groupname)
  end
  return group
end

def add_user_to_group(user, group)
  user.groups << group unless user.groups.include?(group)
  user.save
end

def wait_for_css_element(element)
  page.has_css?(element, :visible => true)
end


def fill_in_for_media_entry_number(n, values)

  # More human-compatible, we fill_in...(1) to fill in the field
  # at index position 0
  media_entry_num = n - 1

  values.each do |k,v|
    # Fills in the "_value" field it finds in the UL that contains
    # the "key" text. e.g. "Titel*" or "Copyright"
    all("ul", :text => /#{k}/)[media_entry_num].all("input").each do |ele|
      fill_in ele[:id], :with => v if ele[:id] =~ /_value$/
    end
  end
  
end

def fill_in_for_batch_editor(values)

  values.each do |k,v|
    # Fills in the "_value" field it finds in the UL that contains
    # the "key" text. e.g. "Titel*" or "Copyright"
    all("ul", :text => /#{k}/).first.all("textarea").each do |ele|
      fill_in ele[:id], :with => v if !ele[:id].match(/attributes_\d+_value$/).nil?
    end
  end

end


def click_media_entry_titled(title)
  entry = find_media_entry_titled(title)
  entry.find("a").click
end

def oldschool_click_media_entry_titled(title)
  all("ul.items li").each do |entry|
    if entry.text =~ /#{title}/
      entry.find("a").click
    end
  end
end


# Sets the checkbox of the media entry with the given title to true.
def check_media_entry_titled(title)
  # Crutch so we can check the otherwise invisible checkboxes (they only appear on hover,
  # which Capybara can't do)
  make_hidden_items_visible
  
  entry = find_media_entry_titled(title)
  cb = entry.find("input")
  cb.click unless cb[:checked] == "true" # a string, not a bool!
end

# Attempts to find a media entry based on its title by looking for
# the .item_box that contains the title. Returns the whole .item_box element
# if successful, nil otherwise.
def find_media_entry_titled(title)
  found_item = nil
  all(".item_box").each do |item|
    #debugger; puts "lala"
    if !item.find(".item_title").text.match(/#{title}/).nil?
      found_item = item
    end
  end

  if found_item == nil
    puts "No media entry found with title '#{title}'"
  end

  return found_item
  
end

# Picks the given text string from an autocomplete text input box
# that is stuck in an UL: ul.ui-autocomplete
def pick_from_autocomplete(text)
  all("ul.ui-autocomplete").each do |ul|
    ul.all("li.ui-menu-item a").each do |item|
      item.click if !item.text.match(/#{text}/).nil?
    end
  end
end


def find_permission_checkbox(type, to_or_from)

  # Currently we find this numerically by index position.
  # To do a better job at this, instead go and find the
  # input type=checkbox which has ?key=edit in its path attribute:
  # <input checked="" path="/media_entries/1/permissions/3?key=view" type="checkbox">
  
  # The HTML in the "everybody" part is different than in the normal table because it splits the checkboxes and
  # text lines with a <br>, therefore our index positions must compensate for that
  # positions: 0 = view for logged in
  #            1 = view for public
  #            2 = edit for logged in
  #            3 = edit for public
  #            4 = download hi-res for logged in
  #            5 = download hi-res for public
  
  if type == "view"
    if to_or_from.class == String
      text = /#{to_or_from}/
      index = 0
    elsif to_or_from == :everybody
      text = "Öffentlich"
      index = 0
    end

  elsif type == "edit"
    if to_or_from.class == String
      text = /#{to_or_from}/
      index = 1
    elsif to_or_from == :everbody
      text = "Öffentlich"
      index = 2
    end

  elsif type == "download_hires"
    if to_or_from.class == String
      text = /#{to_or_from}/
      index = 2
    elsif to_or_from == :everbody
      text = "Öffentlich"
      index = 5
    end
  end
  cb = find(:css, "table.permissions").find("tr", :text => text).all("input")[index]  
end


def give_permission_to(type, to)

  cb = find_permission_checkbox(type, to)
  cb.click unless cb[:checked] == "true" # a string, not a bool!  
end


def remove_permission_to(type, from)
  cb = find_permission_checkbox(type, from)
  cb.click if cb[:checked] == "true" # a string, not a bool!
end



# DANGER: This is now (March 15, 2011) broken due to the way
# Capybara handles fill_in. I believe it used to trigger the keyUp event
# that is necessary for the autocomplete to kick in, but it no longer does
# so, breaking many of our tests. Needs more investigation.
def type_into_autocomplete(type, text)
  if type == :user
    wait_for_css_element("table.permissions")
    wait_for_css_element("#new_user")
    fill_in("new_user", :with => text)
  elsif type == :group
    wait_for_css_element("table.permissions")
    wait_for_css_element("#new_group")
    fill_in("new_group", :with => text)
  elsif type == :add_member_to_group
    wait_for_css_element("#new_user")
    fill_in("new_user", :with => text)
  else
    puts "Unknown autocomplete type '#{type}', please add this type to the method type_into_autocomplete()"
  end
end


def sphinx_reindex
  # This would be the "clean" and "proper" way to do things. However,
  # rspec often causes a race condition where the sphinx_reindex task is
  # finished before the actual rake task has finished, therefore
  # any subsequent searches that _should_ return results do not!
  # So we do it the ugly way, as seen below.
  #   require 'rake'
  #   require 'thinking_sphinx/tasks'
  #   Rake::Task["ts:reindex"].invoke
  #   sleep(4)


  # The ugly way, then.
  # This sends the reindex rake task into the background, so that we're sure
  # the indexer is actually run (in the background!) when we think it is run.
  # Otherwise it might run even more asynchronously, which breaks all of our tests.
  `rake ts:reindex &`
  sleep(1)

  # Note that NONE OF THIS WOULD BE NECESSARY if Sphinx, ThinkingSphinx and Rspec
  # were better aligned and delta indexing would actually work in testing the way it
  # usually works on a real server.
  
end