require 'spec_helper'

include LivingStyleguide

describe LivingStyleguide do

  it 'Module constructs correct tree from fixture dir' do
    dir = 'dev/test/fixtures/living-styleguide-test'
    expected_tree = [
      {
        path: '01_Section1', nr: '1', name: 'Section1',
        elements: [
          { path: '_1_element1.html.haml', nr: '1', name: 'element1' },
          { path: '_2_element2.html.haml', nr: '2', name: 'element2' }
        ]
      },
      {
        path: '02_Section2', nr: '2', name: 'Section2',
        subpath: '_info-only.html.haml',
        elements: nil
      }
    ]
    actual_tree = build_styleguide_tree(dir)
    expect(actual_tree).to eq expected_tree
  end

end
