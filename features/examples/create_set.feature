Feature: Login

  As a MAdeK user
  I want to create sets
  to make collections of media entries

  Background: Load the example data and personas
    Given personas are loaded
      And I am "Normin"

  @javascript
  Scenario: Create set
    When I create a set through the context actions
    Then I see a dialog with an input field for the title
    When I provide a title
    Then I can create a set with that title
    When I created that set
    Then Im redirectet to the detail view of that set