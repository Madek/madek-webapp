require 'spec_helper'

describe MediaEntry do

  it "should be producible by a factory" do
    (ModelFactory.create_media_entry).should_not == nil
  end

end
