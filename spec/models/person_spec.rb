require 'spec_helper'

describe Person do

  it "should be producible by a factory" do
    (FactoryGirl.create :person).should_not == nil
  end


  # In the past, we used to try to second-guess what the user wants and we cased names
  # to this format: "Lastname, Firstname". So people called "LastName, First-Name" would be
  # misrepresented as "Lastname, First-name". We don't want to do that anymore, the user
  # knows how to properly spell a name and we should not mis-manipulate the data. So this test
  # makes sure that we don't manipulate the data anymore.
  it "should not mess with the casing of the first and last name" do
    person = FactoryGirl.create(:person)
    person.firstname = "Hans-Friedrich"
    person.lastname = "Van Den Berg"
    person.save

    person.reload

    person.firstname.should == "Hans-Friedrich" # NOT 'Hans-friedrich'!
    person.lastname.should == "Van Den Berg" # NOT 'Van den berg'!

  end

  it "should parse the first and last name from a string without messing up the casing" do
    person = FactoryGirl.create(:person)
    person.firstname, person.lastname = Person.parse("Van Den Berg, Hans-Friedrich")
    person.save
    person.reload
    person.firstname.should == "Hans-Friedrich" # NOT 'Hans-friedrich'!
    person.lastname.should == "Van Den Berg" # NOT 'Van den berg'!
  end

  it "should leave the casing alone even when using a person in a meta data field" do
    FactoryGirl.create :meta_key, :label => "author", :meta_datum_object_type => "MetaDatumPeople"
    user = FactoryGirl.create(:user)
    me = FactoryGirl.create(:media_entry)
    h = {:meta_data_attributes => {0 => {:meta_key_label => "author", :value => "Van Den Berg, Hans-Friedrich"}}}
    me.reload.update_attributes(h, user)
    me.reload.meta_data.get_value_for("author").should == "Van Den Berg, Hans-Friedrich"
    me.reload.meta_data.get_value_for("author").should_not == "Van den berg, Hans-friedrich"
    me.reload.meta_data.get_value_for("author").should_not == "Hans-Friedrich, Van Den Berg"
  end

end
