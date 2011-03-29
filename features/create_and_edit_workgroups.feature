Feature: Create and edit workgroups

  As a person who has media entries in the system, I might want to edit them
  with other people. So that I don't have to assign permissions on a person-by-person
  basis, I can create workgroups based on users who have logged into the system
  before.


  Background: The world and some users exist
    Given I have set up the world
      And a user called "Porky Pig" with username "porky" and password "piggy" exists
      And a user called "Daffy Duck" with username "daffy" and password "ducky" exists

  
  Scenario: Create a group
    When I log in as "porky" with password "piggy"
     And I click the arrow next to "Pig, Porky"
     And I follow "Meine Arbeitsgruppen"
     And I follow "Neue Arbeitsgruppe erstellen"
     And I fill in "group_name" with "Looney Tunes"
     And I press "Gruppe erstellen"
    Then I should see "Looney Tunes"
     And I should see "Pig, Porky"

  @javascript
  Scenario: Create a group and assign people to it
    When I log in as "porky" with password "piggy"
     And I click the arrow next to "Pig, Porky"
     And I follow "Meine Arbeitsgruppen"
     And I follow "Neue Arbeitsgruppe erstellen"
     And I fill in "group_name" with "Looney Tunes"
     And I press "Gruppe erstellen"
    Then I should see "Looney Tunes"
     And I should see "Pig, Porky"
    When I type "Daff" into the "user" autocomplete field
     And I pick "Duck, Daffy" from the autocomplete field
    Then I should see "Pig, Porky"
     And I should see "Duck, Daffy"

  @javascript @problematic
  Scenario: Create a group, assign people to it, then remove one person
    When I log in as "porky" with password "piggy"
     And I click the arrow next to "Pig, Porky"
     And I follow "Meine Arbeitsgruppen"
     And I follow "Neue Arbeitsgruppe erstellen"
     And I fill in "group_name" with "Looney Tunes"
     And I press "Gruppe erstellen"
    Then I should see "Looney Tunes"
     And I should see "Pig, Porky"
    When I type "Daff" into the "user" autocomplete field
     And I pick "Duck, Daffy" from the autocomplete field
    Then I should see "Pig, Porky"
     And I should see "Duck, Daffy"
    When I remove "Duck, Daffy" from the group
    Then I should see "Pig, Porky"
     And I should not see "Duck, Daffy"