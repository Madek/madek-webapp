require 'spec_helper'

describe Exiftool do

  it "should respond to parse_metadata" do
    Exiftool.respond_to?(:parse_metadata).should == true
  end

  it "should return fiels with files of asked for" do
    res = Exiftool.parse_metadata "features/data/images/berlin_wall_01.jpg" ,["File"]
    res.flatten.grep(/File/).should_not be_empty
  end

end

