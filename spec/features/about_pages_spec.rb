require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

EXAMPLE_CONTENT_RAW = <<MARKDOWN.strip_heredoc.strip
  # About this Archive

  ## Notice

  We use [Cookies](https://en.wikipedia.org/wiki/Cookie). They are quite tasty, *yum*!
MARKDOWN

EXAMPLE_CONTENT_HTML = <<HTML.strip_heredoc.strip
  <h1 id="about-this-archive">About this Archive</h1>

  <h2 id="notice">Notice</h2>

  <p>We use <a href="https://en.wikipedia.org/wiki/Cookie">Cookies</a>. They are quite tasty, <em>yum</em>!</p>
HTML

feature 'Feature: About Pages' do

  it 'shows the content when configured' do
    configure_about_page_content(EXAMPLE_CONTENT_RAW)
    visit '/about'
    content = first('.app-body .bright .ui-markdown')
    expect(content['innerHTML'].strip).to eq EXAMPLE_CONTENT_HTML
  end

  it 'does not serve page when nothing configured' do
    configure_about_page_content(nil)
    visit '/about'
    expect(page).to have_content I18n.t(:error_404_title)
  end

  it 'does not serve page when no content configured' do
    configure_about_page_content('')
    visit '/about'
    expect(page).to have_content I18n.t(:error_404_title)
  end

end

private

def configure_about_page_content(content)
  AppSetting.first.update_attributes!(about_pages: { de: content })
end
