Then /^I take a screenshot$/ do
  case Capybara.current_driver
  when :selenium_chrome
    Rails.logger.warn "can't take screenshot with the chromedriver" 
  else
    Capybara::Screenshot.screenshot_and_save_page
  end
end

Then /^I try to leave the page$/ do
  @current_path = page.current_path
  find("a[href='#{root_path}']").click
end

Then /^I try to import a file with a file size greater than 1.4 GB$/ do
  begin
    path = File.join(::Rails.root, "tmp/file_biger_then_1_4_GB.mov") 
    `dd if=/dev/zero of=#{path} count=3000000` 
    visit import_path
    attach_file(find("input[type='file']")[:id], path)
  ensure
    File.delete path
  end
end


