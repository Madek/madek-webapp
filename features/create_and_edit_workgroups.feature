Feature: Create and edit workgroups

  As a person who has media entries in the system, I might want to edit them
  with other people. So that I don't have to assign permissions on a person-by-person
  basis, I can create workgroups based on users who have logged into the system
  before.


  Background: The world and some users exist
    Given I have set up the world
      And a user called "Porky Pig" with username "porky" and password "piggy" exists
      And a user called "Daffy Duck" with username "daffy" and password "ducky" exists

  @work
  Scenario: Create a group
