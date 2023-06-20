require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

# display oembed result in a page with nothing else so we can do measurements
def do_oembed_client(params)
  # use browser as api client - just grap the JSON from the body:
  visit oembed_path(params)
  res = JSON.parse(find('body > pre').text)
  html_string = res['html']
  visit 'about:blank' # NOTE: makes sure it works from ANY origin
  execute_script "document.body.style = 'margin:0;padding:0;display:inline-block';"
  execute_script "document.body.innerHTML = '#{html_string}';"
  sleep 3 # let the DOM reticulate its spines
end

def expected_embedded_ui(size, caption, link)
  {
    iframe_attrs: size,
    body: size,
    embedded: {
      body: size,
      caption_text: caption,
      caption_link: URI.parse(Settings.madek_external_base_url).merge(link).to_s
    }
  }
end

def displayed_embedded_ui
  # NOTE: text will be nil if its cut off or otherwise hidden - thats on purpose!
  iframe = find('iframe')
  {
    iframe_attrs: { height: iframe[:height].to_i, width: iframe[:width].to_i },
    body: get_actual_size('document.body'),
    embedded:
      page.within_frame(iframe) do
        titlebar = page.all('.vjs-titlebar')[0]
        caption = titlebar.all('.vjs-titlebar-caption')[0]
        {
          body: get_actual_size('document.body'),
          caption_text: caption.try(:text),
          caption_link: titlebar[:href]
        }
      end
  }.deep_symbolize_keys
end

def get_actual_size(selector)
  evaluate_script <<-JS
    (function(){
      var n = #{selector}
      return n && { height: n.offsetHeight, width: n.offsetWidth }
    }())
  JS
end

def get_actual_image_size()
  get_actual_size('document.querySelectorAll("img")[0]')
end

def get_actual_body_size()
  get_actual_size('document.body')
end

def do_manual_embed(url)
  html_string =
    <<-HTML
    <div class="___madek-embed __madek-embed-manual">
      <iframe
      src="#{ERB::Util.html_escape(url)}"
      width="640px" height="360px"
      frameborder="0" style="margin:0;padding:0;border:0"
      sandox=""
    ></iframe></div>
  HTML
      .strip_heredoc
      .tr("\n", ' ')
      .strip
  visit 'about:blank' # NOTE: makes sure it works from ANY origin
  execute_script "document.body.style = 'margin:0;padding:0;display:inline-block';"
  execute_script "document.body.innerHTML = '#{html_string}';"
  sleep 3 # let the DOM reticulate its spines
end

def displayed_embed_error_ui
  page.within_frame(find('iframe')) do
    within('.error-msg-container') do
      {
        title: page.all('h1')[0].try(:text),
        details: page.all('p').map { |p| [p[:class].sub('error-', ''), p.text] }.to_h
      }
    end
  end.deep_symbolize_keys
end

def set_base_url
  # NOTE: make sure absolute URLs work (only needed for manual embeds)
  port = Capybara.current_session.server.port
  Capybara.server_port = port
  Capybara.app_host = "http://localhost:#{port}"
  default_url_options[:host] = Capybara.app_host
end

def absolute_external_url(url)
  URI.parse(Settings[:madek_external_base_url]).merge(URI.parse(url).path).to_s
end
