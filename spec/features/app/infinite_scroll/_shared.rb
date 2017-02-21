require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

def open_view_and_check_loading_on_scroll(path, login: true)
  visit path
  sign_in_as user if login

  box = find('.ui-resources')
  last_visible_page_n = page_number(last_page(box))

  scroll_to_end_of_last_page
  # wait maximum N seconds for at least one more page to load:
  wait_until(20) do
    last_visible_page_n < page_number(last_page(box))
  end
end

def last_page(box)
  box.all('.ui-resources-page').last
end

def page_number(box_page)
  box_page.find('.ui-resources-page-counter')
    .text.split.map(&:to_i).select(&:nonzero?).first
end

def scroll_to_end_of_last_page
  page.execute_script <<-JS
    pages = document.querySelectorAll('.ui-resources .ui-resources-page')
    lastPage = pages[pages.length-1]
    window.scrollTo(0, (lastPage.offsetTop + lastPage.offsetHeight))
  JS
end
