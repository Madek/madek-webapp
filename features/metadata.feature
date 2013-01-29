
Feature: Editing keywords, people, controlled vocabularies...

  @chrome
  Scenario: Changing all meta-data fields of a media entry
    Given I am signed-in as "Normin"
     When I go to the edit-page of my first media_entry
     And I change the value of each meta-data field
     And I click on the button "Speichern"
     Then I am on the page of my first media_entry
     And I can see every meta-data-value somewhere on the page
     When I go to the edit-page of my first media_entry
     Then each meta-data value should be equal to the one set previously
