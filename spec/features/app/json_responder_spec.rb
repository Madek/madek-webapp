require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'App: Responders' do

  describe 'JSON Responder', browser: false do

    REQUEST_ARGS = {
      format: :json,
      list: { page: 1, per_page: 3, order: 'created_at DESC' } }

    it 'full response (MediaEntries index)' do
      result = get_json_url(media_entries_path(REQUEST_ARGS))
      expect(page.status_code).to eq 200
      expect(result[:resources].first[:uuid]).to eq MediaEntry.last.id
    end

    it 'sparse response (MediaEntries index)' do
      sparse_spec = { resources: [{ uuid: {} }], pagination: {} }
      sparse_param = '&___sparse=' + CGI.escape(JSON.generate(sparse_spec))

      result = get_json_url(media_entries_path(REQUEST_ARGS) + sparse_param)
      # check if sparse (top level)
      expect(result.keys).to eq [:resources, :pagination]
      # check if sparse (nested)
      expect(result[:resources].map(&:keys).flatten.uniq).to eq [:uuid]
      # check correct value (nested)
      expect(result[:resources].first[:uuid]).to eq MediaEntry.last.id
    end

  end

end

def get_json_url(url_path)
  visit(url_path)
  JSON.parse(page.text).deep_symbolize_keys
end
