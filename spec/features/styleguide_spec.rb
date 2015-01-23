require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

include LivingStyleguide # builds table of contents so we know what to expect

# BEGIN CONFIG

# screenshots are *really* slow, only run in CI or if 'MADEK_TEST_SCREENSHOTS=1'
def screenshots_enabled_in_environment?
  ENV['MADEK_TEST_SCREENSHOTS'] != 1
end

def regenerate?
  false # for frontend owner only!
end

# END CONFIG

describe 'Styleguide' do

  it 'is rendered without error (index, all-in-one and sections)',
     browser: :headless do

    paths = [
      '/',           # index
      '/Layout',     # a section
      '?expand=true' # all-in-one
    ]
    paths.each do |path|
      url = styleguide_path + path
      puts url
      visit url
    end
  end

  it 'Elements screenshots match the reference', browser: :firefox do
    if screenshots_enabled_in_environment?
      # preparation…
      puts 'styleguide screenshots are enabled, cleaning tmp dir'
      filenname = 'styleguide-shasums.txt'
      reference_hashes = Rails.root.join('dev', 'test', filenname)
      screenshot_dir = Rails.root.join('tmp', 'styleguide-ref')
      FileUtils.rm_r(screenshot_dir, secure: true) if Dir.exists? screenshot_dir

      styleguide_elements = build_styleguide_tree
      .select { |section| !section[:elements].nil? }
      .flat_map do |section|
        section[:elements].map do |element|
          element[:section_name] = section[:name]
          element[:section_path] = section[:path]
          element
        end
      end

      styleguide_elements.map do |element|
        section = element[:section_name]
        element_dir = screenshot_dir.join(section)
        FileUtils.mkdir_p(element_dir) unless Dir.exists? element_dir

        visit styleguide_element_path(section, element[:name])
        move_mouse_over(first 'body a') # for consistent hovering
        take_screenshot(element_dir, "#{element[:name]}.png")
      end

      # regenerate reference hashes
      if regenerate?
        system "shasum --portable tmp/styleguide-ref/**/* > #{reference_hashes}"
      end

      # compare hashes to references
      check = system "shasum --portable -c #{reference_hashes}"

      # attach tar.gz of screenshots if regenerating (reference) or it failed
      if !check || regenerate?
        puts 'Attaching artefacts…'
        system 'cd tmp && tar -cvzf styleguide-ref.tar.gz styleguide-ref/'
      end

      # expect successful hash matches
      expect(check).to eq true

    end

    # catches false-positive (in CI!) if we are regenerating…
    expect(regenerate?).to eq false

  end

end
