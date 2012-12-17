Feature: Create and edit groups

  As a person who has media entries in the system, I might want to edit them
  with other people. So that I don't have to assign permissions on a person-by-person
  basis, I can create workgroups based on users who have logged into the system
  before.

  @poltergeist
  Scenario: Just create a group
    Given I am "normin"
     And I click the arrow next to my name
     And I follow "Meine Arbeitsgruppen"
     And I hover the context actions menu
     And I follow "Neue Arbeitsgruppe"
     And I fill in "name" with "Looney Tunes"
     And I press "Erstellen"
    Then I should see "Looney Tunes"
     And I should see "Normalo, Normin"
     And "Normalo, Normin" should be a member of the "Looney Tunes" group

  @javascript
  Scenario: Create a group, assign people to it
    Given I am "normin"
     And I click the arrow next to my name
     And I follow "Meine Arbeitsgruppen"
     And I hover the context actions menu
     And I follow "Neue Arbeitsgruppe"
     And I fill in "name" with "Looney Tunes"
     And I press "Erstellen"
    Then I should see "Looney Tunes"
     And I should see "Normalo, Normin"
    When I edit the "Looney Tunes" group
     And I type "Lise" into the "add_member_to_group" autocomplete field
     And I pick "Landschaft, Liselotte" from the autocomplete field
    Then I should see "Normalo, Normin"
     And I should see "Landschaft, Liselotte"
     And I press "Speichern"
     And "Landschaft, Liselotte" should be a member of the "Looney Tunes" group
     And "Normalo, Normin" should be a member of the "Looney Tunes" group
    
  @poltergeist
  Scenario: Try to create a group without a name and fail
    Given I am "normin"
     And I click the arrow next to my name
     And I follow "Meine Arbeitsgruppen"
     And I hover the context actions menu
     And I follow "Neue Arbeitsgruppe"
     And I fill in "name" with ""
     And I press "Erstellen"    
    Then I should see "Name can't be blank"
    When I fill in "name" with "Peanuts"
     And I press "Erstellen"    
    Then I should see "Peanuts"
    
