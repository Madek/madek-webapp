Feature: Making top level sets visible (highlight)

  In order be able to focus on top level sets first (sets without parents)
  As a user
  I want to see top parents with a higher priority

  Background: Loading world
  Given I have set up the world
    And personas are loaded

  @javascript
  Scenario: Viewing my sets
    Given I am "Normin"
     When I visit my sets
     Then I see all my sets

  @javascript
  Scenario: Switch between all my sets and all my top level sets
    Given I am "Normin"
      And I am on my sets page
      And I follow "Alle meine Sets"
     Then I see all my sets
     When I follow "Alle meine obersten Sets"
     Then I only see my top level sets
