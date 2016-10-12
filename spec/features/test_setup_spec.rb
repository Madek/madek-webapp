require 'spec_helper'
require 'spec_helper_feature'

feature 'Test Setup' do

    it 'catches JavaScript errors', expect_js_errors: ['negative test'] do
      html = '<!DOCTYPE html><script>throw new Error("negative test")</script>'
      url = 'data:text/html;base64,' + Base64.strict_encode64(html)
      visit(url)
    end

end
