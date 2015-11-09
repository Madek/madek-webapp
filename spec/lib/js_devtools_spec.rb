require 'spec_helper'

# NOTE: This is a smokescreen test to check if browserify etc works.

describe 'JS Devtools' do
  it 'builds' do
    `npm run -s build-devtools`
    expect($?.success?).to be
  end

  it 'accepts script via pipe; has nested Model definitions in scope' do

    script = <<-COFFEESCRIPT
      (new Models.MetaDatum.Text()) instanceof Models.MetaDatum.Text
    COFFEESCRIPT

    stdout = `echo '#{script}' | npm run -s devtools`

    expect(stdout).to eq "coffee> true\ncoffee> coffee> "
  end

end
