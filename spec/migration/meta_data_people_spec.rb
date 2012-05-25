require 'spec_helper'
require 'migration_helpers/meta_datum'

describe "MetaDatum People Migration" do

  context "A MetaDatum with serialized people array" 

  before :each do
    @person1 = FactoryGirl.create :person
    @person2 = FactoryGirl.create :person
    @mr = FactoryGirl.create :media_set

    @rmd = MigrationHelpers::MetaDatum::RawMetaDatum.create media_resource_id: @mr.id,
      meta_key: MetaKey.find(5),
      value: [@person1.id,@person2.id].to_yaml
  end

  it "should be persisted" do
    @rmd.should be_persisted
  end

  describe "migration" do

    it "should not raise an error" do
      expect{MigrationHelpers::MetaDatum.migrate_meta_people}.not_to raise_error
    end

    it "should migratre the entry" do
      MetaDatumPerson.all.size.should == 0
      MigrationHelpers::MetaDatum.migrate_meta_people
      MetaDatumPerson.all.size.should == 1
    end

    it "should set the value to null" do
      MigrationHelpers::MetaDatum.migrate_meta_people
      @rmd.reload.value.should be_nil 
    end

    it "should contain the two person as people" do
      MigrationHelpers::MetaDatum.migrate_meta_people
      MetaDatumPerson.find(@rmd.id).people.should include @person1
      MetaDatumPerson.find(@rmd.id).people.should include @person2
    end

  end
  
end


