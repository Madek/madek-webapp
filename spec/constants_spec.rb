require 'spec_helper'

describe Constants do

  context Constants::Actions do

    context "new2old method"  do

      it "should return :hi_res with :download" do
        (Constants::Actions.new2old :download).should == :hi_res
      end

    end

    context "old2new method"  do

      it "should return :downloadwith :hi_res" do
        (Constants::Actions.old2new :hi_res).should == :download
      end

    end
  end

end
