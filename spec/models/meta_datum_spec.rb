require 'spec_helper'

describe MetaDatum do

  context "a meta_key of type string" do

    let :unsaved_meta_datum  do
      md = MetaDatum.new 
      md.meta_key = MetaKey.find_by_label("title")
      md.value = "Blah"
      md
    end

    it "should not raise an error upon save!" do
      md = unsaved_meta_datum
      expect {md.save!}.not_to raise_error
    end

    it "should be of type MetaDatumString after save!" do
      pending "this will probalby never work; we need to change the way we create MetaDatum in the app"
      md = unsaved_meta_datum
      md.save!()
      md.class.should == MetaDatumString
    end

  end

end


 
