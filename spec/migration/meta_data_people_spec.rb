require 'spec_helper'
require 'migration_helpers/meta_datum'

describe "MetaDatum People Migration" do

  # reset the Person thing
  before :each do
    MetaKey.where("meta_datum_object_type = 'MetaDatumPeople'").each do |mk|
      mk.update_column(:object_type, "Person")
    end
  end

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
      MetaDatumPeople.all.size.should == 0
      MigrationHelpers::MetaDatum.migrate_meta_people
      MetaDatumPeople.all.size.should == 1
    end

    it "should set the value to null" do
      MigrationHelpers::MetaDatum.migrate_meta_people
      @rmd.reload.value.should be_nil 
    end

    it "should contain the two person as people" do
      MigrationHelpers::MetaDatum.migrate_meta_people
      MetaDatumPeople.find(@rmd.id).people.should include @person1
      MetaDatumPeople.find(@rmd.id).people.should include @person2
    end

    it "should migrate the meta_key object type " do
      MigrationHelpers::MetaDatum.migrate_meta_people
      MetaKey.where("object_type = 'Person'").size.should == 0
      MetaKey.where("meta_datum_object_type = 'MetaDatumPeople'").size.should > 0
    end

  end
  
end


