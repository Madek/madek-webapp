require 'spec_helper'

describe User do

  it "should be producible by a factory" do
    (FactoryGirl.create :user).should_not == nil
  end

  it "should be destroyable" do
    expect{ (FactoryGirl.create :user).destroy }.not_to raise_error
  end

  context "referential integrity" do

    it "should raise an execption if the person is deleted on the database layer" do
      user = FactoryGirl.create :user
      expect { SQLHelper.execute_sql "DELETE FROM people WHERE ID = #{user.person.id};" }.to raise_error
    end

  end

end
