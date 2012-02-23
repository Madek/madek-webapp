require 'spec_helper'

describe PermissionPreset do

  it "should be createable " do
    expect {PermissionPreset.create name: "Some Preset Name"}.not_to raise_error
  end

  it "should not be possible to create two presets with equivalent properties" do
    expect {PermissionPreset.create name: "Some Preset Name"}.not_to raise_error
    expect {PermissionPreset.create name: "Second One"}.to raise_error
  end

   it "should not be possible to create two presets with same name" do
    expect {PermissionPreset.create name: "Preset Name"}.not_to raise_error
    expect {PermissionPreset.create name: "Preset Name", view: true}.to raise_error
  end
  
end
