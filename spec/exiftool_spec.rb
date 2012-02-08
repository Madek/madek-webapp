require 'spec_helper'

describe Exiftool do

  it "should respond to parse_metadata" do
    Exiftool.respond_to?(:parse_metadata).should == true
  end

  it "should return fiels with files of asked for" do
    res = Exiftool.parse_metadata "features/data/images/berlin_wall_01.jpg" ,["File"]
    res.flatten.grep(/File/).should_not be_empty
  end

  it "should respond to extract_madek_subjective_metadata" do
    Exiftool.respond_to?(:extract_madek_subjective_metadata).should == true
  end

  it "should extract madek subjective metadata" do
    res = Exiftool.extract_madek_subjective_metadata "features/data/images/date_should_be_from_to_may.jpg", "image"
    res[0][0][0].match(/Author/).should be
    res[0][0][1].match(/Buser/).should be
  end


end

