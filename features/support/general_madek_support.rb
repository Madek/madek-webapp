

Before do
  # This is run before EVERY scenario. It's necessary to prevent
  # tests trying to fetch media entries from cache that don't exist
  # anymore on the database.
  Rails.cache.clear
end



# Need to escape these special characters because they might appear in the
# labels we use in the metadata editor form.
def filter_string_for_regex(string)
  return string.gsub('/', '\\/')\
               .gsub("'","\'")\
               .gsub('(','\\(')\
               .gsub(')','\\)')
end

# Need to escape these special characters because they might appear in the values
# we want to pick from an autocomplete field
def filter_string_for_javascript(string)
  return string.gsub("'","\'")\
               .gsub("(","\(")\
               .gsub(")","\)")
end


def make_hidden_items_visible
  page.execute_script '$(":hidden").show();'
end

def click_on_arrow_next_to(word)
  find(".head_menu", :text => "#{word}").find("img.arrow").click
end

def create_group(groupname)
  group = Group.where(:name => groupname).first
  if group.nil?
    group = Group.create(:name => groupname)
  end
  return group
end

def wait_for_css_element(element)
  page.has_css?(element, :visible => true)
end

def set_term_checkbox(node, text)
#   debugger; puts "lala"
  cb = node.find("ul li ul li", :text => text).find("input")
  cb.click unless cb[:checked] == "true" # a string, not a bool!
end

def select_from_multiselect_widget(node, text)
  node.find(".madek_multiselect_container").find(".search_toggler").click
  pick_from_autocomplete(text)
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
  cb_icon = entry.find(:css, ".check_box").find("img")
  #debugger; puts "lala"
  cb_icon.click if (cb_icon[:src] =~ /_on.png$/).nil? # Only click if it's not yet checked
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


# Options are:
# "pseudonym field": Use the "pseudonym" field instea of first or last name
# "group tab". Switch to the group tab to enter group information
def fill_in_person_widget(list_element, value, options = "")
  if options == "in-field entry box"
    id_prefix = list_element["data-meta_key"]
    field = list_element.find("##{id_prefix}_autocomplete_search")
    fill_in field[:id], :with => value
    press_enter_in(field[:id])
  elsif options == "pseudonym field"
    list_element.find(".dialog_link").click
    fill_in "Pseudonym", :with => value
    click_link_or_button("Personendaten einfügen")
  elsif options == "group tab"
    list_element.find(".dialog_link").click
    click_link "Gruppe"
    sleep 2
    list_element.all("form").each do |form|
      if form[:id] =~ /^new_group/
        group_form_id = form[:id]
         within("##{group_form_id}") do
          fill_in "Name", :with => value
        end
      end
    end
    click_link_or_button("Gruppendaten einfügen")
  else
    lastname, firstname = value, value
    lastname, firstname = value.split(",") if value.include?(",")
    list_element.find(:css, ".dialog_link").click
    fill_in "Nachname", :with => lastname
    fill_in "Vorname", :with => firstname
    click_link_or_button("Personendaten einfügen")
  end
end


def fill_in_keyword_widget(list_element, value, options = "")
  if options == "pick from my keywords tab"
    list_element.find(".dialog_link").click
    list_element.find("li", :title => value).click
  elsif options == "pick from popular keywords tab"
    list_element.find(".dialog_link").click
    click_link "Beliebteste"
    list_element.find("li", :title => value).click
  elsif options == "pick from latest keywords tab"
    list_element.find(".dialog_link").click
    click_link "Neueste"
    list_element.find("li", :title => value).click
  else
    field = list_element.find("#keywords_autocomplete_search")
    fill_in field[:id], :with => value
    press_enter_in(field[:id])
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
    elsif to_or_from == :everybody
      text = "Öffentlich"    
    end
    index = 1
  elsif type == "edit"
    if to_or_from.class == String
      text = /#{to_or_from}/
    elsif to_or_from == :everbody
      text = "Öffentlich"
    end
    index = 3
  elsif type == "download_hires"
    if to_or_from.class == String
      text = /#{to_or_from}/
    elsif to_or_from == :everbody
      text = "Öffentlich"
    end
    index = 5
  end
  cb = find(:css, "table.permissions").find("tr", :text => text).all("input")[index]
end


def give_permission_to(type, to)

  cb = find_permission_checkbox(type, to)
  cb.click unless cb[:checked] == "true" # a string, not a bool!
  click_button("Speichern")
end


def remove_permission_to(type, from)
  cb = find_permission_checkbox(type, from)
  cb.click if cb[:checked] == "true" # a string, not a bool!
  click_button("Speichern")
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
    sleep(1.5)
  elsif type == :group
    wait_for_css_element("table.permissions")
    wait_for_css_element("#new_group")
    fill_in("new_group", :with => text)
    sleep(1.5)
  elsif type == :add_member_to_group
    wait_for_css_element("#new_user")
    fill_in("new_user", :with => text)
    sleep(1.5)
  else
    puts "Unknown autocomplete type '#{type}', please add this type to the method type_into_autocomplete()"
  end
end

# Picks the given text string from an autocomplete text input box
# that is stuck in an UL: ul.ui-autocomplete
def pick_from_autocomplete(text)
  wait_for_css_element("li.ui-menu-item")
  all("ul.ui-autocomplete").each do |ul|
    ul.all("li.ui-menu-item a").each do |item|
      if !item.text.match(/#{filter_string_for_regex(text)}/).nil?
        page.execute_script %Q{ $('.ui-menu-item a:contains("#{item.text}")').trigger("mouseenter").click(); }
      end
    end
  end
end


def press_enter_in(field_id)
enter_script = <<HERE
var e = jQuery.Event("keypress");
e.keyCode = $.ui.keyCode.ENTER;
e.which = $.ui.keyCode.ENTER;
$("##{field_id}").trigger(e);
HERE
  page.execute_script(enter_script)
end

# Uploads a picture with a given title and a fixed copyright string.
# It's always the same picture, no way to change the image file yet.
def upload_some_picture(title = "Untitled")

    visit "/"

    # The upload itself
    click_link("Hochladen")
    click_link("Basic Uploader")
    attach_file("uploaded_data[]", Rails.root + "features/data/images/berlin_wall_01.jpg")
    click_button("Ausgewählte Medien hochladen und weiter…")
    wait_for_css_element("#submit_to_3") # This is the "Einstellungen speichern..." button
    click_button("Einstellungen speichern und weiter…")

    # Entering metadata

    fill_in_for_media_entry_number(1, { "Titel"     => title,
                                        "Copyright" => 'some dude' })

    click_button("Metadaten speichern und weiter…")
    click_link_or_button("Weiter ohne Hinzufügen zu einem Set")

    sphinx_reindex
    visit "/"
   
    page.should have_content(title)

end

# Creates a new set
def create_set(set_title = "Untitled Set")
  visit "/media_sets"
  fill_in "media_set_meta_data_attributes_0_value", :with => set_title
  click_link_or_button "Erstellen"
end

# Adds a media entry to a set. Only works if the media entry
# has a title, so that it shows up under /media_entries. The set
# also needs a title.
def add_to_set(set_title = "Untitled Set", picture_title = "Untitled")
  visit "/media_entries"
  click_media_entry_titled(picture_title)
  click_link_or_button("Zu Set hinzufügen")
  select(set_title, :from => "media_set_ids[]")
  click_link_or_button("Zu ausgewähltem Set hinzufügen")
  # The set title is displayed on the right-hand side of this page, so we should be able to
  # see it here.
  page.should have_content(set_title)
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
