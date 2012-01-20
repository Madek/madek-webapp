Feature: Possibility to browse entries and sets

  In order to be able to browse entries and sets
  As a normal user
  I want to be able to see entries and sets (resources) when i browse the applikation

  Background: Set up the world some users, some sets and entries
    Given I have set up the world
      And a user called "Max" with username "max" and password "moritz" exists
      
      And a set titled "My Act Photos" created by "max" exists
      And a entry titled "Me with Nothing" created by "max" exists
      And the last entry is child of the last set
   
      And a set titled "My Private Images" created by "max" exists
      And a entry titled "Me" created by "max" exists
      And the last entry is child of the last set
      And the last set is parent of the 1st set   
        
      And a public set titled "My Public Images" created by "max" exists
      And a entry titled "My Profile Pic" created by "max" exists
      And the last entry is child of the last set
      
      And a set titled "Football Pics" created by "max" exists
      And a entry titled "Me and my Balls" created by "max" exists
      And the last entry is child of the last set
      And the last set is parent of the 3rd set
      
      And a set titled "Images from School" created by "max" exists
      And a entry titled "Me with School Uniform" created by "max" exists
      And the last entry is child of the last set
      
      And a user called "Moritz" with username "moritz" and password "max" exists
      
      And a public set titled "Photos from Moritz" created by "moritz" exists
      And a entry titled "This is Moritz" created by "moritz" exists
      And the last entry is child of the last set
   
      And a set titled "Moritzs private Images" created by "moritz" exists
      And a entry titled "Moritz" created by "moritz" exists
      And the last entry is child of the last set
      And the last set is parent of the 1st set   
        
      And a set titled "Moritz Public" created by "moritz" exists
      And a entry titled "Moritzs Profiles" created by "moritz" exists
      And the last entry is child of the last set
      
      And a set titled "Hockey Pics" created by "moritz" exists
      And a entry titled "Brackets" created by "moritz" exists
      And the last entry is child of the last set
      And the last set is parent of the 3rd set
      
  @javascript
  Scenario: Max goes to the homepage and want to see his own media entries and public media entries from other users
    When I log in as "max" with password "moritz"
    When I go to the home page
    Then I should see "My Act Photos"
    And I should see "Me with Nothing"
    And I should see "My Private Images"
    And I should see "My Public Images"
    And I should see "Football Pics"
    And I should see "Images from School"
    And I should see "Photos from Moritz"
    And I should not see "This is Moritz"
    And I should not see "Moritzs private Images"
    And I should not see "Moritz Public"
    And I should not see "Moritzs Profiles"
    And I should not see "Hockey Pics"
    And I should not see "Brackets"
    
  @javascript
  Scenario: Moritz goes to the homepage and want to see his own media entries and public media entries from other users
    When I log in as "moritz" with password "max"
    When I go to the home page
    Then I should not see "My Act Photos"
    And I should not see "Me with Nothing"
    And I should not see "My Private Images"
    And I should see "My Public Images"
    And I should not see "Football Pics"
    And I should not see "Images from School"
    And I should see "Photos from Moritz"
    And I should see "This is Moritz"
    And I should see "Moritzs private Images"
    And I should see "Moritz Public"
    And I should see "Moritzs Profiles"
    And I should see "Hockey Pics"
    And I should see "Brackets"
