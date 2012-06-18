Feature: Login

  As a MAdeK user

  Background: Load the example data and personas
    Given I have set up the world a little
      And personas are loaded

  Scenario: Login with database authentication
    When I visit the splash screen
     And I switch to database authentication
     And I fill in my login and password
    Then I'm logged in
