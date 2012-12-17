When /^I open the FTP information dialog$/ do
  find(".open_dropbox_dialog").click
  wait_for_css_element(".ui-dialog")
end