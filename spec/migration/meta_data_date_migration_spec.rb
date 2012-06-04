require 'spec_helper'

require 'migration_helpers/meta_datum'



describe "MetaDatum MetaDate Migration" do

  let :create_ugly_meta_date_entry do
    MigrationHelpers::MetaDatum::RawMetaDatum.create meta_key_id: 8, 
      value: %Q{---
- !ruby/object:MetaDate            
  free_text: 08.12.2010, 14:28     
  timestamp: 1291814880            
  timezone: "+01:00"               
    }
  end


  let :create_and_migrate_ugly do
    mdd = create_ugly_meta_date_entry
    MigrationHelpers::MetaDatum.migrate_meta_date mdd
    mdd.reload
    mdd
  end



  context "ugly serizlized data" do

    describe "creation" do

      it "should not raise an error" do
        expect {create_ugly_meta_date_entry}.not_to raise_error
      end
    end

    describe "migration" do

      it "should not raise an error" do
        expect {create_and_migrate_ugly}.not_to raise_error
      end

      it "should set the string field by contents of the serialized free_text" do 
        create_and_migrate_ugly.string.should == "08.12.2010, 14:28"
      end

    end

  end


  let :create_empty_meta_date_entry do
    MigrationHelpers::MetaDatum::RawMetaDatum.create meta_key_id: 65, 
      value: %Q{--- []   

}
  end

  let :create_and_migrate_empty do
    mdd = create_empty_meta_date_entry
    MigrationHelpers::MetaDatum.migrate_meta_date mdd
    mdd.reload
    mdd
  end

  context "empty data" do
    
    describe "creation" do

      it "should not raise an error" do
        expect {create_empty_meta_date_entry}.not_to raise_error
      end

    end

    describe "migration" do

      it "should not raise an error" do
        expect {create_and_migrate_empty}.not_to raise_error
      end

      it "should set the string field by contents of the serialized free_text" do 
        create_and_migrate_empty.string.should == ""
      end

    end

  end

  describe "Complete Migration" do

    before :each do
      # restore MetaDate types, they have been removed from the minimal setup
      MetaKey.where("meta_datum_object_type = 'MetaDatumDate'").each do |mk|
        mk.update_attributes object_type: "MetaDate"
      end

      create_empty_meta_date_entry
      create_ugly_meta_date_entry
    end

    it "should not raise an error" do
      expect { MigrationHelpers::MetaDatum.migrate_meta_dates}.not_to raise_error
    end

    it "should migrate the two entries" do
      MigrationHelpers::MetaDatum::RawMetaDatum.where("type = 'MetaDatumDate'").size.should == 0
      MigrationHelpers::MetaDatum.migrate_meta_dates
      MigrationHelpers::MetaDatum::RawMetaDatum.where("type = 'MetaDatumDate'").size.should == 2
    end

  end

end
