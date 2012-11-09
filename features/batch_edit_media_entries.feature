Feature: Batch edit media entries

  In order to have a tool which provides functionalities for making a batch operation with multiple selected resources,entries and sets
  As a normal and expert user
  I want to have a widget which provides functions for selecting multiple resources and provides batch-operations for the selection

  @javascript
  Scenario: Remove two media entries from a set using batch edit
   Given I am "Normin" 
   Given I upload some picture titled "Picture One"
     And I upload some picture titled "Picture Two"
     And I upload some picture titled "Picture Three"
    When I create a set titled "Set One"
     And I add the picture "Picture One" to the set "Set One" owned by "Normalo, Normin"
     And I add the picture "Picture Two" to the set "Set One" owned by "Normalo, Normin"
     And I add the picture "Picture Three" to the set "Set One" owned by "Normalo, Normin"
     And I go to the media entries
     And I click the media entry titled "Picture One"
     And I choose the set "Set One" from the media entry
     And I check the media entry titled "Picture One"
     And I check the media entry titled "Picture Two"
     And I open the selection widget for this batchedit
     And I deselect "Set_One" as parent set
     And I submit the selection widget
     And I go to the media entries
     And I click the media entry titled "Picture Three"
     And I choose the set "Set One" from the media entry
    Then I should not see "Picture One"
     And I should not see "Picture Two"

  @javascript
  Scenario: Change metadata on two media entries using batch edit
   Given I am "Normin" 
   Given I upload some picture titled "Picture One"
     And I upload some picture titled "Picture Two"
     And I upload some picture titled "Picture Three"  
    When I create a set titled "Batch Retitle Set"
     And I add the picture "Picture One" to the set "Batch Retitle Set" owned by "Normalo, Normin"
     And I add the picture "Picture Two" to the set "Batch Retitle Set" owned by "Normalo, Normin"
     And I go to the media entries
     And I click the media entry titled "Picture One"
     And I choose the set "Batch Retitle Set" from the media entry
     And I check the media entry titled "Picture One"
     And I check the media entry titled "Picture Two"
     And all the hidden items become visible
     And I press "Metadaten editieren"
     And I fill in the metadata form as follows:
     |label    |value                 |
     |Titel    |We are all individuals|
     And I press "Speichern"
     Then I should see "Die Änderungen wurden gespeichert."
     And I should see "We are all individuals"
     And I go to the media entries
     And I click the media entry titled "We are all individuals"
     Then I should see "We are all individuals"
     And I should not see "Picture One"
     And I should not see "Picture Two"

  @javascript
  Scenario: Use the batch's "Select all" button
    Given I am "Normin" 
      And I am on the homepage
      And I follow "Alle meine Inhalte"
     When I click the mediaset titled "Konzepte"
      And I use batch's deselect all
      And I use batch's select all
     Then I should see that all visible resources are in my batch bar

  @javascript
  Scenario: Different/Same values while batch editing MetaDatumMetaTerms
    Given I am "Karen"
     When I edit two MediaEntries meta data that have the same values for a MetaData with type "MetaDatumMetaTerms"
     Then I should see that this meta data field has same values
     When I edit two MediaEntries meta data that have different values for a MetaData with type "MetaDatumMetaTerms"
     Then I should see that this meta data field has different values
     When I edit two MediaEntries meta data that have the same values for a MetaData with type "MetaDatumKeywords"
     Then I should see that this meta data field has same values
     When I edit two MediaEntries meta data that have different values for a MetaData with type "MetaDatumKeywords"
     Then I should see that this meta data field has different values
     When I edit two MediaEntries meta data that have the same values for a MetaData with type "MetaDatumPeople"
     Then I should see that this meta data field has same values
     When I edit two MediaEntries meta data that have different values for a MetaData with type "MetaDatumPeople"
     Then I should see that this meta data field has different values