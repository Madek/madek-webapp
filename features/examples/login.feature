Feature: Login

  As a MAdeK user

  Background: Load the example data and personas
    Given I have set up the world a little
      And personas are loaded

  @javascript
  Scenario: Login with database authentication
    When I go to the splash screen
     And I switch to database authentication
     And I fill in the following:
      | login       | normin     |
      | password    | password   |
     And I press "Anmelden"
    Then I'm logged in
