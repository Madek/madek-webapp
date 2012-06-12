Feature: Create and edit workgroups

  As a person who has media entries in the system, I might want to edit them
  with other people. So that I don't have to assign permissions on a person-by-person
  basis, I can create workgroups based on users who have logged into the system
  before.


  Background: The world and some users exist
    Given I have set up the world a little
      And a user called "Porky Pig" with username "porky" and password "piggy" exists
      And a user called "Daffy Duck" with username "daffy" and password "ducky" exists

  @javascript
  Scenario: Just create a group
    When I log in as "porky" with password "piggy"
     And I click the arrow next to "Pig, Porky"
     And I follow "Meine Arbeitsgruppen"
     And I press "Neue Arbeitsgruppe erstellen"
     And I fill in "name" with "Looney Tunes"
     And I press "Erstellen"
    Then I should see "Looney Tunes"
     And I should see "Pig, Porky"
     And "Pig, Porky" should be a member of the "Looney Tunes" group

  @javascript
  Scenario: Create a group and assign people to it
    When I log in as "porky" with password "piggy"
     And I click the arrow next to "Pig, Porky"
     And I follow "Meine Arbeitsgruppen"
     And I press "Neue Arbeitsgruppe erstellen"
     And I fill in "name" with "Looney Tunes"
     And I press "Erstellen"
    Then I should see "Looney Tunes"
     And I should see "Pig, Porky"
    When I edit the "Looney Tunes" group
     And I type "Daff" into the "add_member_to_group" autocomplete field
     And I pick "Duck, Daffy" from the autocomplete field
    Then I should see "Pig, Porky"
     And I should see "Duck, Daffy"
     And I press "Speichern"
     And "Duck, Daffy" should be a member of the "Looney Tunes" group
     And "Pig, Porky" should be a member of the "Looney Tunes" group


  @javascript
  Scenario: Create a group, assign people to it, then remove one person
    When I log in as "porky" with password "piggy"
     And I click the arrow next to "Pig, Porky"
     And I follow "Meine Arbeitsgruppen"
     And I press "Neue Arbeitsgruppe erstellen"
     And I fill in "name" with "Looney Tunes"
     And I press "Erstellen"
    Then I should see "Looney Tunes"
     And I should see "Pig, Porky"
    When I edit the "Looney Tunes" group
     And I type "Daff" into the "add_member_to_group" autocomplete field
     And I pick "Duck, Daffy" from the autocomplete field
    Then I should see "Pig, Porky"
     And I should see "Duck, Daffy"
    When I remove "Duck, Daffy" from the group
    Then I should see "Pig, Porky"
     And I press "Speichern"
     And "Duck, Daffy" should not be a member of the "Looney Tunes" group
    When I click the arrow next to "Pig, Porky"
     And I follow "Meine Arbeitsgruppen"
     Then I should not see "Duck, Daffy"


  @javascript
  Scenario: Try to create a group without a name and fail
    When I log in as "porky" with password "piggy"
     And I click the arrow next to "Pig, Porky"
     And I follow "Meine Arbeitsgruppen"
     And I press "Neue Arbeitsgruppe erstellen"
     And I fill in "name" with ""
     And I press "Erstellen"    
    Then I should see "Name can't be blank"
    When I fill in "name" with "Peanuts"
     And I press "Erstellen"    
    Then I should see "Peanuts"
    