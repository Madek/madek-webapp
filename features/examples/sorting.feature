Feature: Sorting Media Resources

  As a MAdeK user

  Background: Load the example data and personas
    Given I have set up the world a little
      And personas are loaded
      And I am "Normin"


  @javascript
  Scenario: Sorting Media Resources by title or author
    When I see the action bar
    Then I can sort by title
    And I can sort by author

