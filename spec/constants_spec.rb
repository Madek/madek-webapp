require 'spec_helper'

describe Constants do

  context Constants::Actions do

    context "new2old method"  do

      it "should return :hi_res with :download_high_resolution" do
        (Constants::Actions.new2old :download_high_resolution).should == :hi_res
      end

    end

    context "old2new method"  do

      it "should return :download_high_resolution with :hi_res" do
        (Constants::Actions.old2new :hi_res).should == :download_high_resolution
      end

    end
  end

end
