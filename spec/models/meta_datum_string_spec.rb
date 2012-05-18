require 'spec_helper'

describe MetaDatumString do

  describe "Creation" do

    it "should be producible by a factory" do
      (FactoryGirl.create :meta_datum_string).should_not == nil
    end

  end

end



