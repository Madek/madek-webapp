require 'spec_helper'
require 'migration_helpers/meta_datum'

describe "MetaDatum String Migration" do

  let :create_mds do
    MigrationHelpers::MetaDatum::RawMetaDatum.create meta_key_id: 3, 
      value:  "The quick brown Fox".to_yaml
  end

  let :create_and_migrate do
    mdd = create_mds
    MigrationHelpers::MetaDatum.migrate_meta_string mdd
    mdd.reload
    mdd
  end


  describe "creation" do
    it "should not raise an error" do
      expect {create_mds}.not_to raise_error
    end
  end

  describe "migration" do

    it "should not raise an error" do
      expect {create_and_migrate}.not_to raise_error
    end

    it "should set the string field by contents of the serialized text" do 
      create_and_migrate.string.should ==  "The quick brown Fox"
    end

  end

  
  describe "Complete Migration" do

    before :each do
      create_mds
    end

    it "should not raise an error" do
      expect { MigrationHelpers::MetaDatum.migrate_meta_strings}.not_to raise_error
    end

    it "should migrate the two entries" do
      MigrationHelpers::MetaDatum::RawMetaDatum.where("type = 'MetaDatumString'").size.should == 0
      MigrationHelpers::MetaDatum.migrate_meta_strings
      MigrationHelpers::MetaDatum::RawMetaDatum.where("type = 'MetaDatumString'").size.should == 1
    end

  end

end
