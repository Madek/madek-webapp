require_relative './_shared'

# History hint: this spec was moved from `madek_integration-tests` submodule

# NOTE: uses personas data! (hardcoded expectations)
VIDEO_ENTRY = '/entries/924057ea-5f9a-4a81-85dc-aa067577d6f1'.freeze
PRIVATE_ENTRY = '/entries/c22b6f3f-55ff-4e56-86f9-233af6f4cdc8'.freeze

PORT = ENV['CAPYBARA_SERVER_PORT'] || 3101
BASE_URL = URI.parse("http://localhost:#{PORT}").freeze

feature 'App: oEmbed endpoint', ci_group: :embed do
  # config:
  OEMBED_REQUIRED_KEYS = %i(type version height).freeze
  OEMBED_TYPES = %w(photo video link rich).freeze
  API_URL = BASE_URL.merge('/oembed').to_s.freeze

  example 'oEmbed discovery link from Resource detail page' do
    EXPECTED_LINKS = [
      {
        type: 'application/json+oembed',
        attrs: {
          rel: 'alternate',
          href: full_url('/oembed?url=%2Fentries%2F924057ea-5f9a-4a81-85dc-aa067577d6f1'),
          title: 'oEmbed Profile: JSON'
        }
      },
      {
        type: 'application/xml+oembed',
        attrs: {
          rel: 'alternate',
          href: full_url('/oembed.xml?url=%2Fentries%2F924057ea-5f9a-4a81-85dc-aa067577d6f1'),
          title: 'oEmbed Profile: XML'
        }
      }
    ].freeze

    visit VIDEO_ENTRY
    EXPECTED_LINKS.each do |link|
      node = find("head link[type=\"#{link[:type]}\"]", visible: false)
      expect(node).to be
      link_attrs = [:rel, :href, :title].map { |prop| [prop, node[prop]] }.to_h
      expect(link_attrs).to eq(link[:attrs])
    end
  end

  describe 'oEmbed API:' do
    # types:
    example '`video` type' do
      REQUIRED_KEYS = [:html, :width, :height, :title].freeze
      expected_src_attr = CGI.escapeHTML('/entries/924057ea-5f9a-4a81-85dc-aa067577d6f1/embedded?height=360&width=640')

      response = get_json(
        set_params_for_url(
          API_URL, url: full_url(VIDEO_ENTRY)))

      expect_valid_oembed_response(response)
      REQUIRED_KEYS.each do |key|
        expect(response[:body][key]).to be_present, "missing prop: #{key}"
      end
      expect(response[:body][:title]).to eq 'A public movie to test public viewing'
      expect(response[:body][:width]).to eq 640
      expect(response[:body][:height]).to eq 360
      expect(response[:body][:provider_name]).to eq 'Media Archive'
      expect(response[:body][:provider_url]).to eq full_url('')
      expect(response[:body][:html]).to include '</iframe>'
      expect(response[:body][:html]).to include 'src="' + full_url(expected_src_attr) + '"'
    end

    # NOTE: more thorough sizing spec in `webapp`!
    it 'supports the `maxwidth` param' do
      max_width = 500
      response = get_json(
        set_params_for_url(
          API_URL, maxwidth: max_width, url: full_url(VIDEO_ENTRY)))

      expect_valid_oembed_response(response)
      expect(response[:body][:width]).to be <= max_width.to_i
    end

    it 'supports the `maxheight` param' do
      pending("it does not support `maxheight` in fact")
      max_height = 300
      response = get_json(
        set_params_for_url(
          API_URL, maxheight: max_height, url: full_url(VIDEO_ENTRY)))

      expect_valid_oembed_response(response)
      expect(response[:body][:height]).to be <= max_height.to_i
    end

    it 'does support XML format' do
      response_xml = Net::HTTP.get_response(URI.parse(set_params_for_url(
          (API_URL + '.xml'), url: full_url(VIDEO_ENTRY))))

      response_json = get_json(
        set_params_for_url(API_URL, url: full_url(VIDEO_ENTRY)))

      xml_body = stringify_values(
        Hash.from_xml(response_xml.body).deep_symbolize_keys[:oembed])
      json_body = stringify_values(response_json[:body])

      expect_valid_oembed_response(response_json)
      expect(xml_body).to eq(json_body), 'XML format has same content as JSON'
    end

    # errors:

    it 'returns error when URL in url `param` is not supported' do
      response = get_json(
        set_params_for_url(API_URL, url: '/my'))
      expect(response[:status]).to be 422
    end

    it 'returns error when resource is not found by url `param`' do
      response = get_json(
        set_params_for_url(API_URL, url: full_url('/entries/does_not_exist')))
      expect(response[:status]).to be 404
    end

    it 'only supports "public" resources, returns correct error' do
      response = get_json(
        set_params_for_url(API_URL, url: full_url(PRIVATE_ENTRY)))
      expect(response[:status]).to be 401
    end

  end

  describe "oembed API for images" do
    describe "basics" do
      let :image_entry do
        FactoryBot.create(:embed_test_image_landscape_entry)
      end

      it 'responds with status OK and all oEmbed values are there' do
        url = full_url("/oembed?url=%2Fentries%2F#{image_entry.id}")
        response = get_json(url)
        
        expect_valid_oembed_response(response)
        expect(response[:body][:version]).to eq '1.0'
        expect(response[:body][:type]).to eq 'rich'
        expect(response[:body][:title]).to eq 'madek-test-image-landscape'
        expect(response[:body][:author_name]).to eq 'Madek Team / Public Domain'
        expect(response[:body][:provider_name]).to eq 'Media Archive'
        expect(response[:body][:provider_url]).to eq full_url('')
        expect(response[:body][:html]).to include '</iframe>'
        expect(response[:body][:width]).to eq 640
        expect(response[:body][:height]).to eq 498
        expected_src_attr = CGI.escapeHTML("/entries/#{image_entry.id}/embedded?height=498&width=640")
        expect(response[:body][:html]).to include 'src="' + full_url(expected_src_attr) + '"'
      end
    end

    describe "iframe size calculation for landscape format (1024 x 709)" do
      let :image_entry do
        FactoryBot.create(:embed_test_image_landscape_entry)
      end

      example 'no parameters -> default width' do
        url = full_url("/oembed?url=%2Fentries%2F#{image_entry.id}")
        response = get_json(url)
        
        expect_valid_oembed_response(response)
        expect(response[:body][:width]).to eq 640
        expect(response[:body][:height]).to eq 443 + 55
      end

      example 'maxwidth 400 -> width 400' do
        url = full_url("/oembed?url=%2Fentries%2F#{image_entry.id}&maxwidth=400")
        response = get_json(url)
        
        expect_valid_oembed_response(response)
        expect(response[:body][:width]).to eq 400
        expect(response[:body][:height]).to eq 277 + 55
      end

      example 'maxwidth 2000 -> width 1024 (avoiding left/right gutter)' do
        url = full_url("/oembed?url=%2Fentries%2F#{image_entry.id}&maxwidth=2000")
        response = get_json(url)
        
        expect_valid_oembed_response(response)
        expect(response[:body][:width]).to eq 1024
        expect(response[:body][:height]).to eq 709 + 55
      end

      example 'maxwidth 1 -> width 1 (no minimum size is enforced)' do
        url = full_url("/oembed?url=%2Fentries%2F#{image_entry.id}&maxwidth=1")
        response = get_json(url)
        
        expect_valid_oembed_response(response)
        expect(response[:body][:width]).to eq 1
        expect(response[:body][:height]).to eq 1 + 55
      end

      example 'maxwidth 400, maxheight 400 -> maxheight has no effect' do
        url = full_url("/oembed?url=%2Fentries%2F#{image_entry.id}&maxwidth=400&maxheight=400")
        response = get_json(url)
        
        expect_valid_oembed_response(response)
        expect(response[:body][:width]).to eq 400
        expect(response[:body][:height]).to eq 277 + 55
      end
      
      example 'maxwidth 1000, maxheight 400 -> maxheight will be applied' do
        url = full_url("/oembed?url=%2Fentries%2F#{image_entry.id}&maxwidth=1000&maxheight=400")
        response = get_json(url)

        expect_valid_oembed_response(response)
        expect(response[:body][:width]).to eq 1000
        expect(response[:body][:height]).to eq 400
      end
    end

    describe "iframe size calculation for portrait format (532 x 768)" do
      let :image_entry do
        FactoryBot.create(:embed_test_image_portrait_entry)
      end
  
      example 'no parameters -> default width, but height constrained to media height' do
        url = full_url("/oembed?url=%2Fentries%2F#{image_entry.id}")
        response = get_json(url)
        
        expect_valid_oembed_response(response)
        expect(response[:body][:width]).to eq 640
        expect(response[:body][:height]).to eq 768 + 55
      end

      example 'maxwidth 400 -> width 400' do
        url = full_url("/oembed?url=%2Fentries%2F#{image_entry.id}&maxwidth=400")
        response = get_json(url)
        
        expect_valid_oembed_response(response)
        expect(response[:body][:width]).to eq 400
        expect(response[:body][:height]).to eq 577 + 55
      end

      example 'maxwidth 1000 -> width 1000, but height constrained to media height' do
        url = full_url("/oembed?url=%2Fentries%2F#{image_entry.id}&maxwidth=1000")
        response = get_json(url)
        
        expect_valid_oembed_response(response)
        expect(response[:body][:width]).to eq 1000
        expect(response[:body][:height]).to eq 768 + 55
      end

      example 'maxwidth 1 -> width 1 (no minimum size is enforced)' do
        url = full_url("/oembed?url=%2Fentries%2F#{image_entry.id}&maxwidth=1")
        response = get_json(url)
        
        expect_valid_oembed_response(response)
        expect(response[:body][:width]).to eq 1
        expect(response[:body][:height]).to eq 1 + 55
      end

      example 'maxwidth 400, maxheight 1000 -> maxheight has no effect' do
        url = full_url("/oembed?url=%2Fentries%2F#{image_entry.id}&maxwidth=400&maxheight=1000")
        response = get_json(url)
        
        expect_valid_oembed_response(response)
        expect(response[:body][:width]).to eq 400
        expect(response[:body][:height]).to eq 577 + 55
      end
      
      example 'maxwidth 400, maxheight 400 -> height is set maxheight' do
        url = full_url("/oembed?url=%2Fentries%2F#{image_entry.id}&maxwidth=400&maxheight=400")
        response = get_json(url)
        
        expect_valid_oembed_response(response)
        expect(response[:body][:width]).to eq 400
        expect(response[:body][:height]).to eq 400
      end

      example 'maxheight 400 -> default width x maxheight' do
        url = full_url("/oembed?url=%2Fentries%2F#{image_entry.id}&maxheight=400")
        response = get_json(url)
        
        expect_valid_oembed_response(response)
        expect(response[:body][:width]).to eq 640
        expect(response[:body][:height]).to eq 400
      end
    end
  end

  private

  def expect_valid_oembed_response(response)
    expect(response[:status]).to be 200
    expect(response[:headers]['content-type']).to \
      match_array ['application/json; charset=utf-8']
    expect(response[:body][:version]).to eq '1.0'
    expect(OEMBED_TYPES).to include(response[:body][:type])
  end

  def get_json(url)
    res = Net::HTTP.get_response(URI.parse(url))
    {
      status: res.code.to_i,
      headers: res.to_hash,
      body: JSON.parse(res.body).deep_symbolize_keys
    }
  end

  def set_params_for_url(url, params)
    URI.parse(url)
      .tap { |u| u.query = CGI.parse(u.query || '').deep_merge(params).to_query }
      .to_s
  end

  def full_url(path)
    BASE_URL.merge(path).to_s
  end

  def stringify_values(obj)
    obj.map {|k,v| [k, v.to_s]}.to_h
  end

end
